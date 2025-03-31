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
    registerFallbackValue(RecipeSavedEvent());
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

  ReceipeItemController buildSut() {
    return ReceipeItemController(
      receipe,
      receipeRepository,
      authUserService,
      analyticsRepository,
    );
  }

  blocTest<ReceipeItemController, ReceipeItemState>(
    "Should be in unsaved state when not saved",
    build: () => buildSut(),
    setUp: () {
      when(() => authUserService.currentUser).thenReturn(authUser);
      when(() => receipeRepository.isReceiptSaved(
            authUser.uid,
            receipeName(),
          )).thenAnswer((_) => Stream.value(false));
    },
    verify: (bloc) =>
        expect(bloc.state, equals(const ReceipeItemStateUnsaved())),
  );

  blocTest<ReceipeItemController, ReceipeItemState>(
    "Should be in saved state when already saved",
    build: () => buildSut(),
    setUp: () {
      when(() => authUserService.currentUser).thenReturn(authUser);
      when(() => receipeRepository.isReceiptSaved(
            authUser.uid,
            receipeName(),
          )).thenAnswer((_) => Stream.value(true));
    },
    verify: (bloc) => expect(bloc.state, equals(const ReceipeItemStateSaved())),
  );

  blocTest<ReceipeItemController, ReceipeItemState>(
    "Should save receipe",
    build: () => buildSut(),
    act: (bloc) => bloc.saveReceipe(),
    setUp: () {
      when(() => authUserService.currentUser).thenReturn(authUser);
      when(() => receipeRepository.saveOneReceipt(
            authUser.uid,
            receipe,
          )).thenAnswer((_) => Future.value());
      when(() => receipeRepository.isReceiptSaved(
            authUser.uid,
            receipeName(),
          )).thenAnswer((_) => Stream.value(true));
    },
    verify: (bloc) => {
      verify(() => receipeRepository.saveOneReceipt(
            authUser.uid,
            receipe,
          )).called(1),
      expect(bloc.state, equals(const ReceipeItemStateSaved()))
    },
  );

  //should emit exception when saving fails
  blocTest<ReceipeItemController, ReceipeItemState>(
    "Should emit error when saving fails",
    build: () => buildSut(),
    act: (bloc) => bloc.saveReceipe(),
    setUp: () {
      when(() => authUserService.currentUser).thenReturn(authUser);

      when(() => receipeRepository.saveOneReceipt(
            authUser.uid,
            receipe,
          )).thenThrow(Exception());

      when(() => receipeRepository.isReceiptSaved(
            authUser.uid,
            receipeName(),
          )).thenThrow(Exception());
    },
    verify: (bloc) => {
      expect(bloc.state,
          equals(const ReceipeItemStateError("Error saving receipe")))
    },
  );

  //should emit error when remove receipe failed
  blocTest<ReceipeItemController, ReceipeItemState>(
    "Should emit error when removing fails",
    build: () => buildSut(),
    act: (bloc) => bloc.removeReceipe(),
    setUp: () {
      when(() => authUserService.currentUser).thenReturn(authUser);

      when(() => receipeRepository.removeSavedReceipe(
            authUser.uid,
            receipeName(),
          )).thenThrow(Exception());

      when(() => receipeRepository.isReceiptSaved(
            authUser.uid,
            receipeName(),
          )).thenThrow(Exception());
    },
    verify: (bloc) => {
      expect(bloc.state,
          equals(const ReceipeItemStateError("Error removing saved receipe")))
    },
  );

  blocTest<ReceipeItemController, ReceipeItemState>(
    "Should remove saved receipe",
    build: () => buildSut(),
    act: (bloc) => bloc.removeReceipe(),
    setUp: () {
      when(() => authUserService.currentUser).thenReturn(authUser);
      when(() => receipeRepository.removeSavedReceipe(
            authUser.uid,
            receipeName(),
          )).thenAnswer((_) => Future.value());

      when(() => receipeRepository.isReceiptSaved(
            authUser.uid,
            receipeName(),
          )).thenAnswer((_) => Stream.value(false));
    },
    verify: (bloc) => {
      verify(() => receipeRepository.removeSavedReceipe(
            authUser.uid,
            receipeName(),
          )).called(1),
      expect(bloc.state, equals(const ReceipeItemStateUnsaved()))
    },
  );
}
