import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';

import '../../../ddd/entity.dart';

abstract class IngredientSerialization {
  static Ingredient fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json["name"],
      quantity: json["quantity"] ?? '1',
      date: json["date"] == null ? null : (json["date"] as Timestamp).toDate(),
      id: json["id"] == null ? null : EntityId(json["id"]),
    );
  }

  static Map<String, dynamic> toJson(Ingredient ingredient) {
    return {
      "id": ingredient.id?.value,
      "name": ingredient.name,
      "quantity": ingredient.quantity,
      "date": ingredient.date,
    };
  }
}
