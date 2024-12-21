import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/user_preferences/application/user_preference_service.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference_question.dart';
import 'package:recipe_ai/user_preferences/presentation/user_preference_submit_btn_controller.dart';

class UserPreferenceServiceMock extends Mock implements UserPreferenceService {}

class AuthUserServiceMock extends Mock implements IAuthUserService {}

void main() {
  late UserPreferenceServiceMock userPreferenceService;
  late AuthUserServiceMock authUserService;
  final questionOne = UserPreferenceQuestionMultipleChoice(
    title: 'Your preference cuisine',
    description: 'Select your preference cuisine',
    type: UserPreferenceQuestionType.multipleChoice,
    options: const ['Italian', 'Chinese', 'Japanese', 'Korean', 'Indian'],
  );
  final questionTwo = UserPreferenceQuestionMultipleChoice(
    title: 'Your preference diet',
    description: 'Select your preference diet',
    type: UserPreferenceQuestionType.multipleChoice,
    options: const ['Vegetarian', 'Vegan', 'Pescetarian', 'Keto'],
  );
  late List<UserPreferenceQuestion> questions;
  final optionSelected1 = ['Italian', 'Japanese', 'Indian'];
  final optionSelected2 = ['Vegan', 'Keto'];
  const preferences = UserPreference({
    'Italian': true,
    'Chinese': false,
    'Japanese': true,
    'Korean': false,
    'Indian': true,
    'Vegetarian': false,
    'Vegan': true,
    'Pescetarian': false,
    'Keto': true,
  });

  const noneSelectedPreferences = UserPreference({
    'Italian': false,
    'Chinese': false,
    'Japanese': false,
    'Korean': false,
    'Indian': false,
    'Vegetarian': false,
    'Vegan': false,
    'Pescetarian': false,
    'Keto': false,
  });

  const user = AuthUser(
    uid: EntityId('uid'),
    email: 'test@gmail.com',
  );

  void selectOptions() {
    for (var option in optionSelected1) {
      (questions[0] as UserPreferenceQuestionMultipleChoice).answer(option);
    }
    for (var option in optionSelected2) {
      (questions[1] as UserPreferenceQuestionMultipleChoice).answer(option);
    }
  }

  setUp(() {
    questions = [questionOne, questionTwo];
    userPreferenceService = UserPreferenceServiceMock();
    authUserService = AuthUserServiceMock();

    when(() => authUserService.currentUser).thenAnswer((_) => user);
  });

  UserPreferenceSubmitBtnController buildSut() {
    return UserPreferenceSubmitBtnController(
      userPreferenceService,
      authUserService,
      seconds: 0,
    );
  }

  blocTest<UserPreferenceSubmitBtnController, UserPreferenceSubmitBtnState>(
    'should be on  initial state by default',
    build: () => buildSut(),
    verify: (bloc) => expect(
      bloc.state,
      UserPreferenceSubmitBtnInitial(),
    ),
  );

  blocTest<UserPreferenceSubmitBtnController, UserPreferenceSubmitBtnState>(
    'should be on loading state when submit',
    build: () => buildSut(),
    setUp: () {
      when(() => userPreferenceService.saveUserPreference(
          user.uid, noneSelectedPreferences)).thenAnswer(
        (_) => Completer<void>().future,
      );
    },
    act: (bloc) {
      bloc.submit(questions);
    },
    verify: (bloc) => expect(
      bloc.state,
      UserPreferenceSubmitBtnLoading(),
    ),
  );

  blocTest<UserPreferenceSubmitBtnController, UserPreferenceSubmitBtnState>(
    'should save the user preferences',
    build: () => buildSut(),
    setUp: () {
      when(() =>
              userPreferenceService.saveUserPreference(user.uid, preferences))
          .thenAnswer(
        (_) => Future.value(),
      );
    },
    act: (bloc) {
      selectOptions();
      bloc.submit(questions);
    },
    verify: (bloc) {
      verify(() =>
              userPreferenceService.saveUserPreference(user.uid, preferences))
          .called(1);
      expect(bloc.state, UserPreferenceSubmitBtnSuccess());
    },
  );

  blocTest<UserPreferenceSubmitBtnController, UserPreferenceSubmitBtnState>(
    'should be on error state when fail to save the user preferences',
    build: () => buildSut(),
    setUp: () {
      when(() => userPreferenceService.saveUserPreference(
          user.uid, noneSelectedPreferences)).thenThrow(
        (_) => Exception('Error'),
      );
    },
    act: (bloc) {
      bloc.submit(questions);
    },
    verify: (bloc) {
      expect(bloc.state, UserPreferenceSubmitBtnError());
    },
  );
}
