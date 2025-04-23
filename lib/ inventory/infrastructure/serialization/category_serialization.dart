import 'package:recipe_ai/ddd/entity.dart';

import '../../domain/model/category.dart';

abstract class CategorySerialization {
  static Category fromJson(Map<String, dynamic> json) {
    return Category(
      id: json["id"] == null ? null : EntityId(json["id"]),
      name: json["name"],
      nameFr: json["nameFr"],
    );
  }

  static Map<String, dynamic> toJson(Category category) {
    return {
      "id": category.id?.value,
      "name": category.name,
      "nameFr": category.nameFr,
    };
  }
}