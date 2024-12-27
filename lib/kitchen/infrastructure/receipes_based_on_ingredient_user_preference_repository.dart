import 'package:dio/dio.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/infrastructure/serialization/receipe_api_serialization.dart';
import 'package:recipe_ai/utils/constant.dart';

import '../domain/repositories/receipes_based_on_ingredient_user_preference_repository.dart';

class FastApiReceipesBasedOnIngredientUserPreferenceRepository
    implements IReceipesBasedOnIngredientUserPreferenceRepository {
  final Dio _dio;

  static const String path =
      "$baseApiUrl/gen-receipe-with-user-preference-and-ingredient";

  const FastApiReceipesBasedOnIngredientUserPreferenceRepository(
    this._dio,
  );

  @override
  Future<List<Receipe>> getReceipesBasedOnIngredientUserPreference(
    EntityId uid,
  ) async {
    final response = await _dio.get('$path/${uid.value}');
    final receipes = response.data['receipes'] as List;

    return receipes.map((e) => ReceipeApiSerialization.fromJson(e)).toList();
  }
}
