import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/home/presentation/receipe_item_controller.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository.dart';

class ReceipeRepositoryMock extends Mock implements IUserReceipeRepository {}

class AuthUserServiceMock extends Mock implements IAuthUserService {}

void main() {
  late IUserReceipeRepository receipeRepository;
  late IAuthUserService authUserService;
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

  setUp(
    () {
      receipeRepository = ReceipeRepositoryMock();
      authUserService = AuthUserServiceMock();
    },
  );

  ReceipeItemController buildSut() {
    return ReceipeItemController(
        receipe, receipeRepository, authUserService, 0);
  }

  blocTest<ReceipeItemController, ReceipeItemState>(
    "Should be in unsaved state when not saved",
    build: () => buildSut(),
    setUp: () {
      when(() => authUserService.currentUser).thenReturn(authUser);
      when(() => receipeRepository.isOneReceiptSaved(
            authUser.uid,
            0,
          )).thenAnswer((_) => Future.value(false));
    },
    verify: (bloc) =>
        expect(bloc.state, equals(const ReceipeItemStateUnsaved())),
  );

  blocTest<ReceipeItemController, ReceipeItemState>(
    "Should be in saved state when already saved",
    build: () => buildSut(),
    setUp: () {
      when(() => authUserService.currentUser).thenReturn(authUser);
      when(() => receipeRepository.isOneReceiptSaved(
            authUser.uid,
            0,
          )).thenAnswer((_) => Future.value(true));
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
            0,
            receipe,
          )).thenAnswer((_) => Future.value());
      when(() => receipeRepository.isOneReceiptSaved(
            authUser.uid,
            0,
          )).thenAnswer((_) => Future.value(true));
    },
    verify: (bloc) => {
      verify(() => receipeRepository.saveOneReceipt(
            authUser.uid,
            0,
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
            0,
            receipe,
          )).thenThrow(Exception());

      when(() => receipeRepository.isOneReceiptSaved(
            authUser.uid,
            0,
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
            "${authUser.uid.value}0",
          )).thenThrow(Exception());

      when(() => receipeRepository.isOneReceiptSaved(
            authUser.uid,
            0,
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
            "${authUser.uid.value}0",
          )).thenAnswer((_) => Future.value());

      when(() => receipeRepository.isOneReceiptSaved(
            authUser.uid,
            0,
          )).thenAnswer((_) => Future.value(false));
    },
    verify: (bloc) => {
      verify(() => receipeRepository.removeSavedReceipe(
            authUser.uid,
            "${authUser.uid.value}0",
          )).called(1),
      expect(bloc.state, equals(const ReceipeItemStateUnsaved()))
    },
  );
}