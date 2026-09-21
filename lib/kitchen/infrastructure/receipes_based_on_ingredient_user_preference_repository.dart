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

  const FastApiReceipesBasedOnIngredientUserPreferenceRepository(this._dio);

  @override
  Future<Either<GenRecipeErrorCode, TranslatedRecipe>>
  getReceipesBasedOnIngredientUserPreference(EntityId uid) async {
    try {
      final response = await _dio.get(
        '$path/${uid.value}',
        options: timeOutOptions,
      );

      return Right(TranslatedRecipe.fromJson(response.data));
    } on DioException catch (e) {
      log(
        'Error while fetching receipes based on ingredient and user preference: ${e.message}',
      );
      return Left(
        _errorCodeOf(e.response?.data) ??
            GenRecipeErrorCode.internalServerError,
      );
    } catch (e) {
      // A 200 whose body is not the expected recipes: fail like a server
      // error rather than let the exception leave the loader spinning.
      log('Unexpected recipe generation response: $e');
      return const Left(GenRecipeErrorCode.internalServerError);
    }
  }

  /// The `code` of an error body, when the server sent its JSON error. A
  /// gateway or a missing service answers with an HTML page instead.
  GenRecipeErrorCode? _errorCodeOf(Object? body) {
    if (body is! Map) return null;
    final code = body['code'];
    return code is String ? genRecipeErrorCodefromString(code) : null;
  }
}

enum GenRecipeErrorCode {
  ingredientNotFound,
  userPreferenceNotFound,
  internalServerError,
}

GenRecipeErrorCode? genRecipeErrorCodefromString(String? errorCode) {
  if (errorCode == null) {
    return null;
  }

  switch (errorCode) {
    case 'ingredient-not-found':
      return GenRecipeErrorCode.ingredientNotFound;
    case 'user-preference-not-found':
      return GenRecipeErrorCode.userPreferenceNotFound;

    default:
      return GenRecipeErrorCode.internalServerError;
  }
}
