import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/home/presentation/home_screen_controller.dart';
import 'package:recipe_ai/receipe/application/retrieve_receipe_from_api_one_time_per_day_usecase.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';

class RetrieveReceipeFromApiOneTimePerDayUsecaseMock extends Mock
    implements RetrieveReceipeFromApiOneTimePerDayUsecase {}

void main() {
  late RetrieveReceipeFromApiOneTimePerDayUsecase
      retrieveReceipeFromApiOneTimePerDayUsecase;
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
  });

  HomeScreenController buildSut() {
    return HomeScreenController(
      retrieveReceipeFromApiOneTimePerDayUsecase,
      now: now,
    );
  }

  blocTest<HomeScreenController, HomeScreenState>(
    'should initialy be in loading state',
    build: () => buildSut(),
    setUp: () {
      when(() => retrieveReceipeFromApiOneTimePerDayUsecase.retrieve(now))
          .thenAnswer(
        (_) => Completer<List<Receipe>>().future,
      );
    },
    verify: (bloc) => {
      expect(bloc.state, equals(const HomeScreenStateLoading())),
    },
  );

  blocTest<HomeScreenController, HomeScreenState>(
    'should loaded user receiepes based on user preferences',
    build: () => buildSut(),
    setUp: () {
      when(() => retrieveReceipeFromApiOneTimePerDayUsecase.retrieve(now))
          .thenAnswer(
        (_) => Future.value(reciepes),
      );
    },
    expect: () => [
      const HomeScreenStateLoaded(reciepes),
    ],
  );

  blocTest<HomeScreenController, HomeScreenState>(
    'should failed when an error occurs',
    build: () => buildSut(),
    setUp: () {
      when(() => retrieveReceipeFromApiOneTimePerDayUsecase.retrieve(now))
          .thenThrow(const RetrieveReceipeException('error'));
    },
    verify: (bloc) => {
      expect(
        bloc.state,
        equals(
          const HomeScreenStateError('error'),
        ),
      ),
    },
  );
}
