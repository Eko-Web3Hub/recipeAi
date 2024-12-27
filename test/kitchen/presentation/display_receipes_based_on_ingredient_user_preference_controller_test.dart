import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/kitchen/domain/repositories/receipes_based_on_ingredient_user_preference_repository.dart';
import 'package:recipe_ai/kitchen/presentation/display_receipes_based_on_ingredient_user_preference_controller.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';

class AuthUserService extends Mock implements IAuthUserService {}

class ReceipesBasedOnIngredientUserPreferenceRepository extends Mock
    implements IReceipesBasedOnIngredientUserPreferenceRepository {}

void main() {
  late IAuthUserService authUserService;
  late IReceipesBasedOnIngredientUserPreferenceRepository
      receipesBasedOnIngredientUserPreferenceRepository;
  const authUser = AuthUser(
    uid: EntityId('uid'),
    email: 'test@gmail.com',
  );

  const receipes = <Receipe>[
    Receipe(
      averageTime: '',
      name: 'name',
      ingredients: [],
      steps: [],
      imageUrl: '',
      totalCalories: '',
    ),
  ];

  setUp(() {
    authUserService = AuthUserService();
    receipesBasedOnIngredientUserPreferenceRepository =
        ReceipesBasedOnIngredientUserPreferenceRepository();
    when(() => authUserService.currentUser).thenReturn(authUser);
  });

  DisplayReceipesBasedOnIngredientUserPreferenceController buildSut() {
    return DisplayReceipesBasedOnIngredientUserPreferenceController(
      authUserService,
      receipesBasedOnIngredientUserPreferenceRepository,
    );
  }

  blocTest<DisplayReceipesBasedOnIngredientUserPreferenceController,
      DisplayReceipesBasedOnIngredientUserPreferenceState>(
    'should initialy be in loading state',
    build: () => buildSut(),
    setUp: () {
      when(() => receipesBasedOnIngredientUserPreferenceRepository
              .getReceipesBasedOnIngredientUserPreference(authUser.uid))
          .thenAnswer((_) => Completer<List<Receipe>>().future);
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
      when(() => receipesBasedOnIngredientUserPreferenceRepository
              .getReceipesBasedOnIngredientUserPreference(authUser.uid))
          .thenAnswer((_) => Future.value(receipes));
    },
    expect: () => [
      DisplayReceipesBasedOnIngredientUserPreferenceLoaded(receipes),
    ],
  );
}
