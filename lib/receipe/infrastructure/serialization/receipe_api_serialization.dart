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
      imageUrl: json["image_url"] ?? "",
    );
  }
}
