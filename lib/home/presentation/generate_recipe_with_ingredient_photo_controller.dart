import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';

abstract class IRecipeIdeasNavigation {
  void goToRecipeIdeas(List<Receipe> recipes);
}

abstract class GenerateRecipeWithIngredientPhotoState {}

class GenerateRecipeWithIngredientPhotoLoading
    extends GenerateRecipeWithIngredientPhotoState {}

class GenerateRecipeWithIngredientPhotoController
    extends Cubit<GenerateRecipeWithIngredientPhotoState> {
  GenerateRecipeWithIngredientPhotoController(
    this._navigation,
  ) : super(GenerateRecipeWithIngredientPhotoLoading()) {
    _load();
  }

  void _load() {
    Future.delayed(
      const Duration(seconds: 2),
      () {
        _navigation.goToRecipeIdeas([]);
      },
    );
  }

  final IRecipeIdeasNavigation _navigation;
}
