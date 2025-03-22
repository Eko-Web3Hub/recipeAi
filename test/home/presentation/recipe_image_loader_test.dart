import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/home/presentation/recipe_image_loader.dart';
import 'package:recipe_ai/utils/function_caller.dart';

class FunctionCallerMock extends Mock implements FunctionsCaller {}

void main() {
  late FunctionsCaller functionsCaller;
  const String recipeName = 'recipe';
  final Map<String, dynamic> response = {'url': 'www.image.com'};

  setUp(() {
    functionsCaller = FunctionCallerMock();
  });

  RecipeImageLoader sut() => RecipeImageLoader(
        functionsCaller,
        recipeName,
      );

  blocTest<RecipeImageLoader, RecipeImageState>(
    'should initialy be loading recipe image',
    build: () => sut(),
    setUp: () {
      when(() => functionsCaller.callFunction(any(), any())).thenAnswer(
        (_) => Completer<Map<String, dynamic>>().future,
      );
    },
    verify: (bloc) {
      expect(bloc.state, RecipeImageLoading());
    },
  );

  blocTest<RecipeImageLoader, RecipeImageState>(
    'should load the recipe image url',
    build: () => sut(),
    setUp: () {
      when(() => functionsCaller.callFunction(any(), any())).thenAnswer(
        (_) => Future.value(response),
      );
    },
    expect: () => [RecipeImageLoaded(response['url'])],
  );
}
