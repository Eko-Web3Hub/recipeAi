import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';

abstract class IngredientSerialization {
  static Ingredient fromJson(Map<String, dynamic> json) {
    return Ingredient(name: json["name"], quantity: json["quantity"],
      date: json["date"] == null? null: (json["date"] as Timestamp).toDate(),
    );
  }

  static Map<String, dynamic> toJson(Ingredient ingredient) {
    return {
      "name": ingredient.name,
      "quantity": ingredient.quantity,
      "date": ingredient.date,
    };
  }
}
