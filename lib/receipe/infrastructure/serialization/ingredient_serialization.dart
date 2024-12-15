import 'package:recipe_ai/receipe/domain/model/ingredient.dart';

abstract class IngredientSerialization {
  static Ingredient fromJson(Map<String, dynamic> json) {
  return Ingredient(name: json["name"], quantity: json["quantity"]);
  }
}
