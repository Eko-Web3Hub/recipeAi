import 'package:dartz/dartz.dart';
import 'package:recipe_ai/analytics/analytics_event.dart';
import 'package:recipe_ai/analytics/analytics_repository.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/kitchen/domain/repositories/receipes_based_on_ingredient_user_preference_repository.dart';
import 'package:recipe_ai/kitchen/infrastructure/receipes_based_on_ingredient_user_preference_repository.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:collection/collection.dart';

import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository_v2.dart';

class RetrieveRecipesBasedOnUserIngredientAndPreferencesUsecase {
  const RetrieveRecipesBasedOnUserIngredientAndPreferencesUsecase(
    this._receipesBasedOnIngredientUserPreferenceRepository,
    this._authUserService,
    this._userReceipeRepositoryV2,
    this._analyticsRepository,
  );

  RetrieveRecipesBasedOnUserIngredientAndPreferencesUsecase.inject()
      : this(
          di<IReceipesBasedOnIngredientUserPreferenceRepository>(),
          di<IAuthUserService>(),
          di<IUserReceipeRepositoryV2>(),
          di<IAnalyticsRepository>(),
        );

  Future<Either<GenRecipeErrorCode, List<UserReceipeV2>>> retrieve(
      EntityId uid) async {
    final uid = _authUserService.currentUser!.uid;
    final receipesTranslated =
        await _receipesBasedOnIngredientUserPreferenceRepository
            .getReceipesBasedOnIngredientUserPreference(uid);

    return receipesTranslated.fold(
      (error) {
        return Left(error);
      },
      (translatedRecipe) async {
        final convertRecipesToUserRecipes = translatedRecipe.recipesEn
            .mapIndexed(
              (index, recipe) => convertTranslatedRecipeToUserReciepe(
                id: null,
                recipeFr: translatedRecipe.recipesFr[index],
                recipeEn: recipe,
                createdDate: DateTime.now(),
              ),
            )
            .toList();
        final userRecipeSaved = await _userReceipeRepositoryV2.save(
          uid,
          convertRecipesToUserRecipes,
        );

        _analyticsRepository
            .logEvent(RecipesGeneratedWithIngredientListEvent());
        return Right(userRecipeSaved);
      },
    );
  }

  final IReceipesBasedOnIngredientUserPreferenceRepository
      _receipesBasedOnIngredientUserPreferenceRepository;
  final IAuthUserService _authUserService;
  final IUserReceipeRepositoryV2 _userReceipeRepositoryV2;
  final IAnalyticsRepository _analyticsRepository;
}

UserReceipeV2 convertTranslatedRecipeToUserReciepe({
  EntityId? id,
  required Receipe recipeFr,
  required Receipe recipeEn,
  required DateTime createdDate,
  bool isForHome = false,
  bool isAddedToFavorites = false,
}) =>
    UserReceipeV2(
      createdDate: createdDate,
      id: id,
      receipeFr: recipeFr,
      receipeEn: recipeEn,
      isForHome: isForHome,
      isAddedToFavorites: isAddedToFavorites,
    );
