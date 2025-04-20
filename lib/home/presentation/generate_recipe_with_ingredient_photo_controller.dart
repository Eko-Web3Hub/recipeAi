import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/kitchen/application/retrieve_recipes_based_on_user_ingredient_and_preferences_usecase.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository_v2.dart';

abstract class IRecipeIdeasNavigation {
  void goToRecipeIdeas(List<UserReceipeV2> recipes);
}

abstract class GenerateRecipeWithIngredientPhotoState {}

class GenerateRecipeWithIngredientPhotoLoading
    extends GenerateRecipeWithIngredientPhotoState {}

class GenerateRecipeWithIngredientPhotoSuccess
    extends GenerateRecipeWithIngredientPhotoState {}

class GenerateRecipeWithIngredientPhotoFailure
    extends GenerateRecipeWithIngredientPhotoState {}

class GenerateRecipeWithIngredientPhotoController
    extends Cubit<GenerateRecipeWithIngredientPhotoState> {
  GenerateRecipeWithIngredientPhotoController(
    this._navigation,
    this._userReceipeRepository,
    this._authUserService,
    this.file,
  ) : super(GenerateRecipeWithIngredientPhotoLoading()) {
    _load();
  }

  void _load() async {
    final recipes = await _userReceipeRepository
        .genererateRecipesWithIngredientPicture(file);
    if (recipes != null) {
      final recipesToUserRecipes = recipes.recipesEn
          .mapIndexed<UserReceipeV2>(
              (index, userRecipe) => convertTranslatedRecipeToUserReciepe(
                    recipeFr: recipes.recipesFr[index],
                    recipeEn: userRecipe,
                    createdDate: DateTime.now(),
                  ))
          .toList();
      final userRecipesSaved = await _userReceipeRepository.save(
        _authUserService.currentUser!.uid,
        recipesToUserRecipes,
      );

      _navigation.goToRecipeIdeas(userRecipesSaved);
      emit(GenerateRecipeWithIngredientPhotoSuccess());
    } else {
      emit(GenerateRecipeWithIngredientPhotoFailure());
    }
  }

  final IRecipeIdeasNavigation _navigation;
  final IUserReceipeRepositoryV2 _userReceipeRepository;
  final IAuthUserService _authUserService;
  final File file;
}
