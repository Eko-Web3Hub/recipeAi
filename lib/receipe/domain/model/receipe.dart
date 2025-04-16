import 'package:equatable/equatable.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';
import 'package:recipe_ai/receipe/domain/model/step.dart';
import 'package:recipe_ai/receipe/infrastructure/serialization/receipe_api_serialization.dart';

class Receipe extends Equatable {
  final String name;
  final List<Ingredient> ingredients;
  final List<ReceipeStep> steps;
  final String averageTime;
  final String totalCalories;
  final EntityId? firestoreRecipeId;

  const Receipe({
    required this.name,
    required this.ingredients,
    required this.steps,
    required this.averageTime,
    required this.totalCalories,
    this.firestoreRecipeId,
  });

  Receipe assignFirestoreRecipeId(EntityId id) => _copyWith(
        firestoreRecipeId: id,
      );

  Receipe _copyWith({
    String? name,
    List<Ingredient>? ingredients,
    List<ReceipeStep>? steps,
    String? averageTime,
    String? totalCalories,
    EntityId? firestoreRecipeId,
  }) {
    return Receipe(
      name: name ?? this.name,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      averageTime: averageTime ?? this.averageTime,
      totalCalories: totalCalories ?? this.totalCalories,
      firestoreRecipeId: firestoreRecipeId ?? this.firestoreRecipeId,
    );
  }

  @override
  List<Object?> get props => [
        name,
        ingredients,
        steps,
        averageTime,
        totalCalories,
        firestoreRecipeId,
      ];
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
