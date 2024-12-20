import 'package:recipe_ai/receipe/domain/model/ingredient.dart';

abstract class IngredientSerialization {
  static Ingredient fromJson(Map<String, dynamic> json) {
    return Ingredient(name: json["name"], quantity: json["quantity"]);
  }

  static Map<String, dynamic> toJson(Ingredient ingredient) {
    return {
      "name": ingredient.name,
      "quantity": ingredient.quantity,
    };
  }
}
