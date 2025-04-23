import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/utils/constant.dart';

import '../domain/repositories/receipes_based_on_ingredient_user_preference_repository.dart';

class FastApiReceipesBasedOnIngredientUserPreferenceRepository
    implements IReceipesBasedOnIngredientUserPreferenceRepository {
  final Dio _dio;

  static const String path =
      "$baseApiUrl/v2/gen-receipe-with-user-preference-and-ingredient";

  const FastApiReceipesBasedOnIngredientUserPreferenceRepository(
    this._dio,
  );

  @override
  Future<TranslatedRecipe> getReceipesBasedOnIngredientUserPreference(
    EntityId uid,
  ) async {
    try {
      final response = await _dio.get('$path/${uid.value}');

      return TranslatedRecipe.fromJson(
        response.data,
      );
    } on DioException catch (e) {
      final error =
          'Error while fetching receipes based on ingredient and user preference: ${e.message}';
      log(error);
      throw Exception(
        error,
      );
    }
  }
}
