import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository_v2.dart';
import 'package:recipe_ai/receipe/presentation/receipe_details_controller.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/constant.dart';

class TranslationControllerMock extends Mock implements TranslationController {}

class UserReceipeRepositoryV2Mock extends Mock
    implements IUserReceipeRepositoryV2 {}

void main() {
  late TranslationController translationController;
  late IUserReceipeRepositoryV2 userReceipeRepositoryV2;

  const receipeId = EntityId('1');

  const receipeEn = Receipe(
    name: 'nameEn',
    ingredients: [],
    steps: [],
    averageTime: '',
    totalCalories: '',
  );
  const receipeFr = Receipe(
    name: 'nameFr',
    ingredients: [],
    steps: [],
    averageTime: '',
    totalCalories: '',
  );

  final userRecipe = UserRecipeV2(
    id: receipeId,
    receipeFr: receipeFr,
    receipeEn: receipeEn,
    createdDate: DateTime(2024, 1, 1),
  );

  setUp(() {
    translationController = TranslationControllerMock();
    userReceipeRepositoryV2 = UserReceipeRepositoryV2Mock();
  });

  ReceipeDetailsController buildSut() {
    return ReceipeDetailsController(
      receipeId,
      0,
      translationController,
      userReceipeRepositoryV2,
    );
  }

  blocTest<ReceipeDetailsController, ReceipeDetailsState>(
    'should load the receipe details in the current app language (en)',
    build: () => buildSut(),
    setUp: () {
      when(
        () => userReceipeRepositoryV2.getRecipeById(receipeId),
      ).thenAnswer((_) => Future.value(userRecipe));
      when(
        () => translationController.currentLanguageEnum,
      ).thenReturn(AppLanguage.en);
    },
    expect: () => [
      ReceipeDetailsState.loaded(userRecipe.receipeEn, userRecipe),
    ],
  );

  blocTest<ReceipeDetailsController, ReceipeDetailsState>(
    'should load the receipe details in the current app language (fr)',
    build: () => buildSut(),
    setUp: () {
      when(
        () => userReceipeRepositoryV2.getRecipeById(receipeId),
      ).thenAnswer((_) => Future.value(userRecipe));
      when(
        () => translationController.currentLanguageEnum,
      ).thenReturn(AppLanguage.fr);
    },
    expect: () => [
      ReceipeDetailsState.loaded(userRecipe.receipeFr, userRecipe),
    ],
  );

  blocTest<ReceipeDetailsController, ReceipeDetailsState>(
    'should load the receipe details from the fromReceipe constructor',
    setUp: () {
      when(
        () => translationController.currentLanguageEnum,
      ).thenReturn(AppLanguage.en);
    },
    build: () => ReceipeDetailsController.fromReceipe(
      userRecipe,
      translationController,
      userReceipeRepositoryV2,
    ),
    verify: (bloc) {
      expect(
        bloc.state,
        ReceipeDetailsState.loaded(userRecipe.receipeEn, userRecipe),
      );
    },
  );
}
