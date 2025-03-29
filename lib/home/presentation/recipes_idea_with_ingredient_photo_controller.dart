import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';

class RecipesIdeaWithIngredientPhotoController extends Cubit<List<Receipe>?> {
  RecipesIdeaWithIngredientPhotoController(
    this.recipes,
    this.translationController,
  ) : super(null) {
    _load();
  }

  void _load() {
    final currentLanguage = translationController.currentLanguageEnum;

    if (currentLanguage.name == 'en') {
      emit(recipes.recipesEn);
    } else if (currentLanguage.name == 'fr') {
      emit(recipes.recipesFr);
    }
  }

  final TranslatedRecipe recipes;
  final TranslationController translationController;
}
