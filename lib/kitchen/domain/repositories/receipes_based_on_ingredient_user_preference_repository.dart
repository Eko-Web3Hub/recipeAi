import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';

abstract class IReceipesBasedOnIngredientUserPreferenceRepository {
  Future<TranslatedRecipe> getReceipesBasedOnIngredientUserPreference(
    EntityId uid,
  );
}
