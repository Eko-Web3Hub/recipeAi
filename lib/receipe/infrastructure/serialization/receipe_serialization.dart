import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/step.dart';
import 'package:recipe_ai/receipe/infrastructure/serialization/ingredient_serialization.dart';
import 'package:recipe_ai/receipe/infrastructure/serialization/receipe_step_serialization.dart';

abstract class ReceipeSerialization {
  static Receipe fromJson(Map<String, dynamic> json) {
    return Receipe(
      name: json["name"],
      ingredients: (json["ingredients"] as List)
          .map<Ingredient>(
            (ingredient) => IngredientSerialization.fromJson(ingredient),
          )
          .toList(),
      steps: (json["steps"] as List)
          .map<ReceipeStep>(
            (step) => ReceipeStepSerialization.fromJson(step),
          )
          .toList(),
      averageTime: json["averageTime"],
      totalCalories: json["totalCalories"],
      firestoreRecipeId: json["firestoreRecipeId"] != null
          ? EntityId(json["firestoreRecipeId"])
          : null,
      tags: json["tags"] == null
          ? const []
          : List<String>.from(json["tags"] as List),
      difficulty: json["difficulty"],
      proteinGrams: json["proteinGrams"],
      carbsGrams: json["carbsGrams"],
      lipidsGrams: json["lipidsGrams"],
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
      "averageTime": receipe.averageTime,
      "totalCalories": receipe.totalCalories,
      "firestoreRecipeId": receipe.firestoreRecipeId?.value,
      "tags": receipe.tags,
      "difficulty": receipe.difficulty,
      "proteinGrams": receipe.proteinGrams,
      "carbsGrams": receipe.carbsGrams,
      "lipidsGrams": receipe.lipidsGrams,
    };
  }
}
