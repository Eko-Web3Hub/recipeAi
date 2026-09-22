import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/kitchen/infrastructure/receipes_based_on_ingredient_user_preference_repository.dart';

class _DioMock extends Mock implements Dio {}

/// What the generation URL answers since its Cloud Run service is gone.
const _gatewayNotFoundPage = '''
<html><head>
<title>404 Page not found</title>
</head>
<body><h1>Error: Page not found</h1></body></html>''';

void main() {
  late Dio dio;
  const uid = EntityId('uid');

  setUpAll(() => registerFallbackValue(Options()));
  setUp(() => dio = _DioMock());

  FastApiReceipesBasedOnIngredientUserPreferenceRepository sut() =>
      FastApiReceipesBasedOnIngredientUserPreferenceRepository(dio);

  void answerWithError({required int statusCode, required Object? body}) {
    final request = RequestOptions(path: '');
    when(() => dio.get(any(), options: any(named: 'options'))).thenThrow(
      DioException(
        requestOptions: request,
        response: Response(
          requestOptions: request,
          statusCode: statusCode,
          data: body,
        ),
      ),
    );
  }

  test('an HTML error page is a server error, not a crash', () async {
    answerWithError(statusCode: 404, body: _gatewayNotFoundPage);

    final result = await sut().getReceipesBasedOnIngredientUserPreference(uid);

    expect(result, const Left(GenRecipeErrorCode.internalServerError));
  });

  test('reads the error code of a JSON error body', () async {
    answerWithError(statusCode: 404, body: {'code': 'ingredient-not-found'});

    final result = await sut().getReceipesBasedOnIngredientUserPreference(uid);

    expect(result, const Left(GenRecipeErrorCode.ingredientNotFound));
  });

  test('a JSON error body without a readable code is a server error', () async {
    answerWithError(statusCode: 500, body: {'code': 42});

    final result = await sut().getReceipesBasedOnIngredientUserPreference(uid);

    expect(result, const Left(GenRecipeErrorCode.internalServerError));
  });

  test('no response at all (network down) is a server error', () async {
    when(() => dio.get(any(), options: any(named: 'options'))).thenThrow(
      DioException(requestOptions: RequestOptions(path: '')),
    );

    final result = await sut().getReceipesBasedOnIngredientUserPreference(uid);

    expect(result, const Left(GenRecipeErrorCode.internalServerError));
  });

  test('a success whose body is not recipes is a server error', () async {
    when(() => dio.get(any(), options: any(named: 'options'))).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: _gatewayNotFoundPage,
      ),
    );

    final result = await sut().getReceipesBasedOnIngredientUserPreference(uid);

    expect(result, const Left(GenRecipeErrorCode.internalServerError));
  });
}
