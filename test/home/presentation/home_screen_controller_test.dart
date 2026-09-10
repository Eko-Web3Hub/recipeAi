import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/home/presentation/home_screen_controller.dart';
import 'package:recipe_ai/receipe/application/retrieve_receipe_from_api_one_time_per_day_usecase.dart';
import 'package:recipe_ai/receipe/application/user_recipe_service.dart';
import 'package:recipe_ai/receipe/domain/model/mock_user_receipes.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';

class RetrieveReceipeFromApiOneTimePerDayUsecaseMock extends Mock
    implements RetrieveReceipeFromApiOneTimePerDayUsecase {}

class UserRecipeServiceMock extends Mock implements IUserRecipeService {}

void main() {
  late RetrieveReceipeFromApiOneTimePerDayUsecase
  retrieveReceipeFromApiOneTimePerDayUsecase;
  late IUserRecipeService userRecipeService;

  DateTime now = DateTime(2024, 10, 2);

  const receipe = Receipe(
    name: 'receipeName',
    ingredients: [],
    steps: [],
    averageTime: 'averageTime',
    totalCalories: 'totalCalories',
  );

  final recipes = [
    UserRecipeV2(
      id: const EntityId('id'),
      receipeFr: receipe,
      receipeEn: receipe,
      createdDate: now,
    ),
  ];

  setUp(() {
    retrieveReceipeFromApiOneTimePerDayUsecase =
        RetrieveReceipeFromApiOneTimePerDayUsecaseMock();
    userRecipeService = UserRecipeServiceMock();
  });

  HomeScreenController buildSut() {
    return HomeScreenController(
      retrieveReceipeFromApiOneTimePerDayUsecase,
      userRecipeService,
      now: now,
    );
  }

  blocTest<HomeScreenController, HomeScreenState>(
    'should reload user receipes based on user preferences',
    build: () => buildSut(),
    setUp: () {
      when(
        () => retrieveReceipeFromApiOneTimePerDayUsecase.retrieve(now),
      ).thenAnswer((_) => Future.value(recipes));
    },
    act: (bloc) async {
      await pumpEventQueue();
      await bloc.reload();
    },
    expect: () => [
      const HomeScreenStateLoading(),
      HomeScreenStateLoaded(recipes),
    ],
  );

  blocTest<HomeScreenController, HomeScreenState>(
    'should regenerate user receipe',
    build: () => buildSut(),
    setUp: () {
      when(
        () => retrieveReceipeFromApiOneTimePerDayUsecase.retrieve(now),
      ).thenAnswer((_) => Future.value(recipes));
      when(
        () => userRecipeService.removeLastRecipesHomeUpdatedDate(),
      ).thenAnswer((_) => Future.value());
    },
    act: (bloc) async {
      await pumpEventQueue();
      await bloc.regenerateUserReceipe();
    },
    verify: (bloc) {
      verify(
        () => userRecipeService.removeLastRecipesHomeUpdatedDate(),
      ).called(1);
    },
    expect: () => [
      const HomeScreenStateLoading(),
      HomeScreenStateLoaded(recipes),
    ],
  );

  blocTest<HomeScreenController, HomeScreenState>(
    'should fall back to the mock receipe when an error occurs',
    build: () => buildSut(),
    setUp: () {
      when(
        () => retrieveReceipeFromApiOneTimePerDayUsecase.retrieve(now),
      ).thenThrow(const RetrieveReceipeException());
    },
    act: (bloc) async {
      await pumpEventQueue();
      await bloc.reload();
    },
    expect: () => [
      const HomeScreenStateLoading(),
      HomeScreenStateLoaded([mockSaladeBassamoiseUserReceipe]),
    ],
  );

  blocTest<HomeScreenController, HomeScreenState>(
    'should require login when the user is not authenticated',
    build: () => buildSut(),
    setUp: () {
      when(
        () => retrieveReceipeFromApiOneTimePerDayUsecase.retrieve(now),
      ).thenThrow(const UserNotAuthenticatedException());
    },
    act: (bloc) async {
      await pumpEventQueue();
      await bloc.reload();
    },
    expect: () => [
      const HomeScreenStateLoading(),
      const HomeScreenStateRequiresLogin(),
    ],
  );
}
