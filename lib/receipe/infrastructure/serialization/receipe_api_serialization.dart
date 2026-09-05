import 'package:recipe_ai/receipe/domain/model/ingredient.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/step.dart';
import 'package:recipe_ai/receipe/infrastructure/serialization/ingredient_serialization.dart';
import 'package:recipe_ai/receipe/infrastructure/serialization/receipe_step_serialization.dart';

abstract class ReceipeApiSerialization {
  static Receipe fromJson(Map<String, dynamic> json) {
    return Receipe(
      name: json["name"] ?? "",
      ingredients: json["ingredients"] == null
          ? []
          : (json["ingredients"] as List)
              .map<Ingredient>(
                (ingredient) => IngredientSerialization.fromJson(ingredient),
              )
              .toList(),
      steps: (json["steps"] == null)
          ? []
          : (json["steps"] as List)
              .map<ReceipeStep>(
                (step) => ReceipeStepSerialization.fromJson(step),
              )
              .toList(),
      averageTime: json["average_time"] ?? "",
      totalCalories: json["total_calories"] ?? "",
      tags: json["tags"] == null
          ? const []
          : List<String>.from(json["tags"] as List),
      difficulty: json["difficulty"],
      proteinGrams: json["protein_grams"],
      carbsGrams: json["carbs_grams"],
      lipidsGrams: json["lipids_grams"],
    );
  }

  static Map<String, dynamic> toJson(Receipe receipe) {
    return {
      "name": receipe.name,
      "ingredients": receipe.ingredients
          .map(
            (e) => IngredientSerialization.toJson(e),
          )
          .toList(),
      "steps": receipe.steps
          .map(
            (e) => ReceipeStepSerialization.toJson(e),
          )
          .toList(),
      "average_time": receipe.averageTime,
      "total_calories": receipe.totalCalories,
      "tags": receipe.tags,
      "difficulty": receipe.difficulty,
      "protein_grams": receipe.proteinGrams,
      "carbs_grams": receipe.carbsGrams,
      "lipids_grams": receipe.lipidsGrams,
    };
  }
}
