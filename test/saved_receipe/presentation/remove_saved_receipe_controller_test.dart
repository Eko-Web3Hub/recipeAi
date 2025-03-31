import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/analytics/analytics_event.dart';
import 'package:recipe_ai/analytics/analytics_repository.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/home/presentation/receipe_item_controller.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository.dart';
import 'package:recipe_ai/saved_receipe/presentation/remove_saved_receipe_controller.dart';

class ReceipeRepositoryMock extends Mock implements IUserReceipeRepository {}

class AuthUserServiceMock extends Mock implements IAuthUserService {}

class AnalyticsRepositoryMock extends Mock implements IAnalyticsRepository {}

void main() {
  late IUserReceipeRepository receipeRepository;
  late IAuthUserService authUserService;
  late IAnalyticsRepository analyticsRepository;
  const AuthUser authUser = AuthUser(
    uid: EntityId("uid"),
    email: "test@gmail.com",
  );
  const receipe = Receipe(
      name: "name",
      ingredients: [],
      steps: [],
      averageTime: "",
      totalCalories: "");

  String receipeName() {
    return receipe.name.toLowerCase().replaceAll(' ', '');
  }

  setUpAll(() {
    registerFallbackValue(RecipeUnSaveEvent());
  });

  setUp(
    () {
      receipeRepository = ReceipeRepositoryMock();
      authUserService = AuthUserServiceMock();
      analyticsRepository = AnalyticsRepositoryMock();

      when(() => analyticsRepository.logEvent(any())).thenAnswer(
        (_) => Future.value(),
      );
    },
  );

  RemoveSavedReceipeController buildSut() {
    return RemoveSavedReceipeController(
      receipeRepository,
      authUserService,
      analyticsRepository,
    );
  }

  blocTest<RemoveSavedReceipeController, ReceipeItemState>(
    'should initialy be in saved state',
    build: () => buildSut(),
    verify: (bloc) => {
      expect(bloc.state, equals(const ReceipeItemStateSaved())),
    },
  );

  blocTest<RemoveSavedReceipeController, ReceipeItemState>(
    'Should remove saved receipe',
    build: () => buildSut(),
    setUp: () {
      when(
        () => authUserService.currentUser,
      ).thenReturn(authUser);
      when(() => receipeRepository.removeSavedReceipe(
            authUser.uid,
            receipeName(),
          )).thenAnswer(
        (_) => Future.value(),
      );
    },
    act: (bloc) => bloc.removeReceipe(receipeName()),
    verify: (bloc) => {
      verify(() => receipeRepository.removeSavedReceipe(
            authUser.uid,
            receipeName(),
          )).called(1),
    },
  );

  blocTest<RemoveSavedReceipeController, ReceipeItemState>(
    "Should emit error when removing fails",
    build: () => buildSut(),
    act: (bloc) => bloc.removeReceipe(receipeName()),
    setUp: () {
      when(() => authUserService.currentUser).thenReturn(authUser);

      when(() => receipeRepository.removeSavedReceipe(
            authUser.uid,
            receipeName(),
          )).thenThrow(Exception());
    },
    verify: (bloc) => {
      expect(bloc.state,
          equals(const ReceipeItemStateError("Error removing receipe")))
    },
  );
}
