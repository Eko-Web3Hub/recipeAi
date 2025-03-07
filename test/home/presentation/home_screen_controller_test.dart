import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/home/presentation/home_screen_controller.dart';
import 'package:recipe_ai/receipe/application/retrieve_receipe_from_api_one_time_per_day_usecase.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository.dart';

class RetrieveReceipeFromApiOneTimePerDayUsecaseMock extends Mock
    implements RetrieveReceipeFromApiOneTimePerDayUsecase {}

class UserReceipeRepositoryMock extends Mock
    implements IUserReceipeRepository {}

class AuthUserServiceMock extends Mock implements IAuthUserService {}

void main() {
  late RetrieveReceipeFromApiOneTimePerDayUsecase
      retrieveReceipeFromApiOneTimePerDayUsecase;
  late IUserReceipeRepository userReceipeRepository;
  late IAuthUserService authUserService;
  const authUser = AuthUser(
    uid: EntityId('uid'),
    email: 'test@gmail.com',
  );

  DateTime now = DateTime(2024, 10, 2);

  const reciepes = [
    Receipe(
      name: 'receipeName',
      ingredients: [],
      steps: [],
      averageTime: 'averageTime',
      totalCalories: 'totalCalories',
    ),
  ];

  setUp(() {
    retrieveReceipeFromApiOneTimePerDayUsecase =
        RetrieveReceipeFromApiOneTimePerDayUsecaseMock();
    userReceipeRepository = UserReceipeRepositoryMock();
    authUserService = AuthUserServiceMock();

    when(
      () => authUserService.currentUser,
    ).thenReturn(
      authUser,
    );
  });

  HomeScreenController buildSut() {
    return HomeScreenController(
      retrieveReceipeFromApiOneTimePerDayUsecase,
      userReceipeRepository,
      authUserService,
      now: now,
    );
  }

  blocTest<HomeScreenController, HomeScreenState>(
    'should reload user receiepes based on user preferences',
    build: () => buildSut(),
    setUp: () {
      when(() => retrieveReceipeFromApiOneTimePerDayUsecase.retrieve(now))
          .thenAnswer(
        (_) => Future.value(reciepes),
      );
    },
    act: (bloc) async {
      await pumpEventQueue();
      await bloc.reload();
    },
    expect: () => [
      const HomeScreenStateLoading(),
      const HomeScreenStateLoaded(reciepes),
    ],
  );

  blocTest<HomeScreenController, HomeScreenState>(
    'should regenerate user receipe',
    build: () => buildSut(),
    setUp: () {
      when(() => retrieveReceipeFromApiOneTimePerDayUsecase.retrieve(now))
          .thenAnswer(
        (_) => Future.value(reciepes),
      );
      when(
        () => userReceipeRepository.deleteUserReceipe(
          authUser.uid,
        ),
      ).thenAnswer(
        (_) => Future.value(),
      );
    },
    act: (bloc) async {
      await pumpEventQueue();
      await bloc.regenerateUserReceipe();
    },
    verify: (bloc) {
      verify(
        () => userReceipeRepository.deleteUserReceipe(
          authUser.uid,
        ),
      ).called(1);
    },
    expect: () => [
      const HomeScreenStateLoading(),
      const HomeScreenStateLoaded(reciepes),
    ],
  );

  blocTest<HomeScreenController, HomeScreenState>(
    'should failed when an error occurs',
    build: () => buildSut(),
    setUp: () {
      when(() => retrieveReceipeFromApiOneTimePerDayUsecase.retrieve(now))
          .thenThrow(
        const RetrieveReceipeException(),
      );
    },
    act: (bloc) async {
      await pumpEventQueue();
      await bloc.reload();
    },
    verify: (bloc) => {
      expect(
        bloc.state,
        equals(
          const HomeRetrieveReceipeException(),
        ),
      ),
    },
  );
}
