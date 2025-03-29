import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository.dart';

abstract class IRecipeIdeasNavigation {
  void goToRecipeIdeas(TranslatedRecipe recipes);
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
    this.file,
  ) : super(GenerateRecipeWithIngredientPhotoLoading()) {
    _load();
  }

  void _load() async {
    final recipes = await _userReceipeRepository
        .genererateRecipesWithIngredientPicture(file);
    if (recipes != null) {
      _navigation.goToRecipeIdeas(recipes);
      emit(GenerateRecipeWithIngredientPhotoSuccess());
    } else {
      emit(GenerateRecipeWithIngredientPhotoFailure());
    }
  }

  final IRecipeIdeasNavigation _navigation;
  final IUserReceipeRepository _userReceipeRepository;
  final File file;
}
