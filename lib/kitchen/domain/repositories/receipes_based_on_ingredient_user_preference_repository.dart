import 'package:dartz/dartz.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/kitchen/infrastructure/receipes_based_on_ingredient_user_preference_repository.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';

abstract class IReceipesBasedOnIngredientUserPreferenceRepository {
  Future<Either<GenRecipeErrorCode, TranslatedRecipe>>
      getReceipesBasedOnIngredientUserPreference(
    EntityId uid,
  );
}
