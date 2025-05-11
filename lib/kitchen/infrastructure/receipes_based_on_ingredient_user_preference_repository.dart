import 'dart:developer';

import 'package:dartz/dartz.dart';
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
  Future<Either<GenRecipeErrorCode, TranslatedRecipe>>
      getReceipesBasedOnIngredientUserPreference(
    EntityId uid,
  ) async {
    try {
      final response = await _dio.get('$path/${uid.value}');

      return Right(TranslatedRecipe.fromJson(
        response.data,
      ));
    } on DioException catch (e) {
      final error =
          'Error while fetching receipes based on ingredient and user preference: ${e.message}';
      log(error);
      final response = e.response;

      if (response == null) {
        return Left(
          GenRecipeErrorCode.internalServerError,
        );
      }
      final errorCode = genRecipeErrorCodefromString(
          (response.data as Map<String, dynamic>)['code']);
      log(
        'Error code: $errorCode',
      );

      if (errorCode == null) {
        return Left(
          GenRecipeErrorCode.internalServerError,
        );
      }

      return Left(
        errorCode,
      );
    }
  }
}

enum GenRecipeErrorCode {
  ingredientNotFound,
  internalServerError,
}

GenRecipeErrorCode? genRecipeErrorCodefromString(String? errorCode) {
  if (errorCode == null) {
    return null;
  }

  switch (errorCode) {
    case 'ingredient-not-found':
      return GenRecipeErrorCode.ingredientNotFound;

    default:
      return GenRecipeErrorCode.internalServerError;
  }
}
