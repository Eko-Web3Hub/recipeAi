import 'package:collection/collection.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/kitchen/domain/repositories/receipes_based_on_ingredient_user_preference_repository.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository_v2.dart';

class RetrieveRecipesBasedOnUserIngredientAndPreferencesUsecase {
  const RetrieveRecipesBasedOnUserIngredientAndPreferencesUsecase(
    this._receipesBasedOnIngredientUserPreferenceRepository,
    this._authUserService,
    this._userReceipeRepositoryV2,
  );

  Future<List<UserReceipeV2>> retrieve(EntityId uid) async {
    final uid = _authUserService.currentUser!.uid;
    final receipesTranslated =
        await _receipesBasedOnIngredientUserPreferenceRepository
            .getReceipesBasedOnIngredientUserPreference(uid);

    final convertRecipesToUserRecipes = receipesTranslated.recipesEn
        .mapIndexed(
          (index, recipe) => convertTranslatedRecipeToUserReciepe(
            id: null,
            recipeFr: receipesTranslated.recipesFr[index],
            recipeEn: recipe,
            createdDate: DateTime.now(),
          ),
        )
        .toList();
    final userRecipeSaved = await _userReceipeRepositoryV2.save(
      uid,
      convertRecipesToUserRecipes,
    );

    return userRecipeSaved;
  }

  final IReceipesBasedOnIngredientUserPreferenceRepository
      _receipesBasedOnIngredientUserPreferenceRepository;
  final IAuthUserService _authUserService;
  final IUserReceipeRepositoryV2 _userReceipeRepositoryV2;
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
