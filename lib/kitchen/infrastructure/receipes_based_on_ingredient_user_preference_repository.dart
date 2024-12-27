import 'package:dio/dio.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';

import '../domain/repositories/receipes_based_on_ingredient_user_preference_repository.dart';

class FastApiReceipesBasedOnIngredientUserPreferenceRepository
    implements IReceipesBasedOnIngredientUserPreferenceRepository {
  final Dio _di;

  const FastApiReceipesBasedOnIngredientUserPreferenceRepository(
    this._di,
  );

  @override
  Future<List<Receipe>> getReceipesBasedOnIngredientUserPreference(
    EntityId uid,
  ) async {
    throw UnimplementedError();
  }
}
