import 'package:equatable/equatable.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';
import 'package:recipe_ai/receipe/domain/model/step.dart';
import 'package:recipe_ai/receipe/infrastructure/serialization/receipe_api_serialization.dart';

class Receipe extends Equatable {
  final String name;
  final List<Ingredient> ingredients;
  final List<ReceipeStep> steps;
  final String averageTime;
  final String totalCalories;

  const Receipe({
    required this.name,
    required this.ingredients,
    required this.steps,
    required this.averageTime,
    required this.totalCalories,
  });

  @override
  List<Object?> get props =>
      [name, ingredients, steps, averageTime, totalCalories];
}

class TranslatedRecipe {
  const TranslatedRecipe({
    required this.recipesEn,
    required this.recipesFr,
  });

  factory TranslatedRecipe.fromJson(Map<String, dynamic> json) {
    final recipesEn = (json['recipesEn'] as List)
        .map((recipe) => ReceipeApiSerialization.fromJson(recipe))
        .toList();
    final recipesFr = (json['recipesFr'] as List)
        .map((recipe) => ReceipeApiSerialization.fromJson(recipe))
        .toList();

    return TranslatedRecipe(
      recipesEn: recipesEn,
      recipesFr: recipesFr,
    );
  }

  final List<Receipe> recipesEn;
  final List<Receipe> recipesFr;
}
