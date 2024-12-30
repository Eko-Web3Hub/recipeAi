import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/home/presentation/receipe_item_controller.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository.dart';
import 'package:recipe_ai/saved_receipe/presentation/remove_saved_receipe_controller.dart';



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

  RemoveSavedReceipeController buildSut() {
    return RemoveSavedReceipeController(
        "uid0", receipeRepository, authUserService);
  }


   blocTest<RemoveSavedReceipeController, ReceipeItemStatus>(
    'should initialy be in saved state',
    build: () => buildSut(),
    verify: (bloc) => {
      expect(bloc.state, ReceipeItemStatus.saved),
    },
  );

  blocTest<RemoveSavedReceipeController, ReceipeItemStatus>(
    'Should remove saved receipe',
    build: () => buildSut(),
    setUp: () {
      when(
        () => authUserService.currentUser,
      ).thenReturn(authUser);
      when(() => receipeRepository.removeSavedReceipe(
            authUser.uid,
            "uid0",
          )).thenAnswer(
        (_) => Future.value(),
      );

    },
    act: (bloc) => bloc.removeReceipe(),
    verify: (bloc) => {
      verify(() => receipeRepository.removeSavedReceipe(
            authUser.uid,
            "uid0",
          )).called(1),
      },
  );




   
}