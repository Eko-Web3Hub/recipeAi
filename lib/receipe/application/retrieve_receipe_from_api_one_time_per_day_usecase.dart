import 'package:collection/collection.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/kitchen/application/retrieve_recipes_based_on_user_ingredient_and_preferences_usecase.dart';
import 'package:recipe_ai/receipe/application/user_recipe_service.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository_v2.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_recipe_translate.dart';
import 'package:recipe_ai/user_account/domain/repositories/user_account_meta_data_repository.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/functions.dart';

class RetrieveReceipeException implements Exception {
  const RetrieveReceipeException();
}

class RetrieveReceipeFromApiOneTimePerDayUsecase {
  final IUserReceipeRepository _userReceipeRepository;
  final IAuthUserService _authUserService;
  final IUserReceipeRepositoryV2 _userReceipeRepositoryV2;
  final IUserRecipeService _userRecipeService;

  const RetrieveReceipeFromApiOneTimePerDayUsecase(
    this._userReceipeRepository,
    this._authUserService,
    this._userReceipeRepositoryV2,
    this._userRecipeService,
  );

  Future<List<UserReceipeV2>> retrieve(DateTime now) async {
    try {
      final uid = _authUserService.currentUser!.uid;
      final userRecipeMetadata =
          await _userRecipeService.getUserRecipeMetadata(uid);

      if (userRecipeMetadata == null) {
        return _retrieveAndSave(now);
      }

      final lastUpdatedDate = userRecipeMetadata.lastRecipesHomeUpdatedDate;

      if (now.difference(lastUpdatedDate).inDays >= 1) {
        final receipes = await _retrieveAndSave(now);

        return receipes;
      } else {
        return currentUserReceipe.receipes;
      }
    } catch (e) {
      throw const RetrieveReceipeException();
    }
  }

  Future<List<UserReceipeV2>> _retrieveAndSave(DateTime now) async {
    final uid = _authUserService.currentUser!.uid;

    final recipes = await _userReceipeRepository
        .getReceipesBasedOnUserPreferencesFromApi(uid);

    final convertRecipesToUserRecipes = recipes.recipesEn
        .mapIndexed<UserReceipeV2>(
            (index, recipe) => convertTranslatedRecipeToUserReciepe(
                  recipeFr: recipes.recipesFr[index],
                  recipeEn: recipe,
                  createdDate: now,
                  isAddedToFavorites: false,
                  isForHome: true,
                ))
        .toList();
    final savedUserRecipes = await _userReceipeRepositoryV2.save(
      uid,
      convertRecipesToUserRecipes,
    );

    _userRecipeService.saveUserReceipeMetadata(
      uid,
      now,
    );

    return savedUserRecipes;
  }
}
