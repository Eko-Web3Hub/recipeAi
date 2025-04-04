import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/application/user_recipe_translate_service.dart';

import 'package:recipe_ai/receipe/presentation/receipe_details_controller.dart';
import 'package:recipe_ai/utils/constant.dart';

class UserRecipeTranslateServiceMock extends Mock
    implements UserRecipeTranslateService {}

void main() {
  const EntityId receipeId = EntityId('1');
  late UserRecipeTranslateService recipeTranslateService;

  setUp(() {
    recipeTranslateService = UserRecipeTranslateServiceMock();
  });

  ReceipeDetailsController buildSut() {
    return ReceipeDetailsController(
      receipeId,
      0,
      recipeTranslateService,
    );
  }

  blocTest<ReceipeDetailsController, ReceipeDetailsState>(
    'should load the receipe details',
    build: () => buildSut(),
    expect: () => <ReceipeDetailsState>[
      ReceipeDetailsState.loaded(
        receipeSample,
      ),
    ],
  );

  blocTest<ReceipeDetailsController, ReceipeDetailsState>(
    'should load the receipe details from the fromReceipe constructor',
    build: () => ReceipeDetailsController.fromReceipe(
        receipeSample, recipeTranslateService),
    verify: (bloc) {
      expect(
        bloc.state,
        ReceipeDetailsState.loaded(
          receipeSample,
        ),
      );
    },
  );
}
