import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/kitchen/application/retrieve_recipes_based_on_user_ingredient_and_preferences_usecase.dart';
import 'package:recipe_ai/kitchen/infrastructure/receipes_based_on_ingredient_user_preference_repository.dart';
import 'package:recipe_ai/kitchen/presentation/display_receipes_based_on_ingredient_user_preference_controller.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';

class AuthUserService extends Mock implements IAuthUserService {}

class RetrieveRecipesBasedOnUserIngredientAndPreferencesUsecaseMock
    extends Mock
    implements RetrieveRecipesBasedOnUserIngredientAndPreferencesUsecase {}

void main() {
  late IAuthUserService authUserService;
  late RetrieveRecipesBasedOnUserIngredientAndPreferencesUsecase
      retrieveRecipesBasedOnUserIngredientAndPreferencesUsecase;
  const authUser = AuthUser(
    uid: EntityId('uid'),
    email: 'test@gmail.com',
  );

  const receipe = Receipe(
    averageTime: '',
    name: 'name',
    ingredients: [],
    steps: [],
    totalCalories: '',
  );

  final recipes = [
    UserRecipeV2(
      id: const EntityId('id'),
      receipeFr: receipe,
      receipeEn: receipe,
      createdDate: DateTime(2024, 1, 1),
    ),
  ];

  setUp(() {
    authUserService = AuthUserService();
    retrieveRecipesBasedOnUserIngredientAndPreferencesUsecase =
        RetrieveRecipesBasedOnUserIngredientAndPreferencesUsecaseMock();
    when(() => authUserService.currentUser).thenReturn(authUser);
  });

  DisplayReceipesBasedOnIngredientUserPreferenceController buildSut() {
    return DisplayReceipesBasedOnIngredientUserPreferenceController(
      authUserService,
      retrieveRecipesBasedOnUserIngredientAndPreferencesUsecase,
    );
  }

  blocTest<DisplayReceipesBasedOnIngredientUserPreferenceController,
      DisplayReceipesBasedOnIngredientUserPreferenceState>(
    'should initialy be in loading state',
    build: () => buildSut(),
    setUp: () {
      when(() => retrieveRecipesBasedOnUserIngredientAndPreferencesUsecase
              .retrieve(authUser.uid))
          .thenAnswer(
        (_) =>
            Completer<Either<GenRecipeErrorCode, List<UserRecipeV2>>>().future,
      );
    },
    verify: (bloc) {
      expect(bloc.state,
          isA<DisplayReceipesBasedOnIngredientUserPreferenceLoading>());
    },
  );

  blocTest<DisplayReceipesBasedOnIngredientUserPreferenceController,
      DisplayReceipesBasedOnIngredientUserPreferenceState>(
    'should load receipes',
    build: () => buildSut(),
    setUp: () {
      when(() => retrieveRecipesBasedOnUserIngredientAndPreferencesUsecase
              .retrieve(authUser.uid))
          .thenAnswer((_) => Future.value(Right(recipes)));
    },
    expect: () => [
      DisplayReceipesBasedOnIngredientUserPreferenceLoaded(recipes),
    ],
  );
}
