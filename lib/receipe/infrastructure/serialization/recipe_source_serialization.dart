import 'package:recipe_ai/receipe/domain/model/recipe_source.dart';

abstract class RecipeSourceSerialization {
  static RecipeSource fromJson(Map<String, dynamic> json) {
    return RecipeSource(
      type: recipeSourceTypeFromString(json["type"] as String),
      value: json["value"] as String,
    );
  }

  static Map<String, dynamic> toJson(RecipeSource source) {
    return {"type": source.type.name, "value": source.value};
  }
}
