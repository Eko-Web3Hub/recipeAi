import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference_question.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/user_preference_quizz_repository.dart';
import 'package:recipe_ai/user_preferences/presentation/user_preference_quizz_controller.dart';
import 'package:recipe_ai/utils/constant.dart';

class UserPreferenceQuizzRepository extends Mock
    implements IUserPreferenceQuizzRepository {}

void main() {
  late IUserPreferenceQuizzRepository userPreferenceQuizzRepository;
  final questions = [
    UserPreferenceQuestionMultipleChoice(
      title: 'title',
      description: 'description',
      type: UserPreferenceQuestionType.multipleChoice,
      options: const [
        Option(label: 'option1', key: 'option1'),
        Option(label: 'option2', key: 'option2'),
      ],
    ),
  ];
  const appLanguage = AppLanguage.en;

  setUp(() {
    userPreferenceQuizzRepository = UserPreferenceQuizzRepository();
  });

  UserPreferenceQuizzController buildSut() {
    return UserPreferenceQuizzController(
      userPreferenceQuizzRepository,
      currentUserLanguage: appLanguage,
    );
  }

  blocTest<UserPreferenceQuizzController, UserPreferenceQuizzState>(
    'should initialy be loading',
    build: () => buildSut(),
    setUp: () {
      when(() => userPreferenceQuizzRepository.retrieve(appLanguage))
          .thenAnswer(
        (_) => Completer<List<UserPreferenceQuestion>>().future,
      );
    },
    verify: (bloc) => expect(
      bloc.state,
      UserPreferenceQuizzLoading(),
    ),
  );

  blocTest<UserPreferenceQuizzController, UserPreferenceQuizzState>(
    'should emit loaded state when repository returns questions',
    build: () => buildSut(),
    setUp: () {
      when(() => userPreferenceQuizzRepository.retrieve(appLanguage))
          .thenAnswer(
        (_) => Future.value(questions),
      );
    },
    expect: () => [
      UserPreferenceQuizzLoaded(questions),
    ],
  );

  blocTest<UserPreferenceQuizzController, UserPreferenceQuizzState>(
    'should emit error state when repository throws an exception',
    build: () => buildSut(),
    setUp: () {
      when(() => userPreferenceQuizzRepository.retrieve(appLanguage)).thenThrow(
        Exception(),
      );
    },
    verify: (bloc) => expect(
      bloc.state,
      UserPreferenceQuizzError(),
    ),
  );
}
