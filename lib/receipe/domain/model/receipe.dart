import 'package:equatable/equatable.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';
import 'package:recipe_ai/receipe/domain/model/step.dart';
import 'package:recipe_ai/receipe/infrastructure/serialization/ingredient_serialization.dart';
import 'package:recipe_ai/receipe/infrastructure/serialization/receipe_api_serialization.dart';
import 'package:recipe_ai/receipe/infrastructure/serialization/receipe_step_serialization.dart';

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

class RecipeFindWithImage {
  const RecipeFindWithImage(
    this.name,
    this.ingredients,
    this.steps,
    this.averageTime,
    this.totalCalories,
  );

  final String name;
  final List<Ingredient> ingredients;
  final List<ReceipeStep> steps;
  final String averageTime;
  final String totalCalories;

  factory RecipeFindWithImage.fromJson(Map<String, dynamic> json) {
    return RecipeFindWithImage(
      json['name'] as String,
      (json['ingredients'] as List)
          .map((ingredient) => IngredientSerialization.fromJson(ingredient))
          .toList(),
      (json['steps'] as List)
          .map((step) => ReceipeStepSerialization.fromJson(step))
          .toList(),
      json['average_time'] as String,
      json['total_calories'] is String
          ? json['total_calories']
          : (json['total_calories'] as int).toString(),
    );
  }
}

class RawRecipeFindWithImage {
  final RecipeFindWithImage recipeEn;
  final RecipeFindWithImage recipeFr;

  const RawRecipeFindWithImage({
    required this.recipeEn,
    required this.recipeFr,
  });

  factory RawRecipeFindWithImage.fromJson(Map<String, dynamic> json) {
    return RawRecipeFindWithImage(
      recipeEn: RecipeFindWithImage.fromJson(json['recipeEn']),
      recipeFr: RecipeFindWithImage.fromJson(json['recipeFr']),
    );
  }
}
