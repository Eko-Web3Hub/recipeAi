import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference_question.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/user_preference_quizz_repository.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/user_preference_repository.dart';
import 'package:recipe_ai/user_preferences/presentation/user_preference_update_controller.dart';
import 'package:recipe_ai/utils/constant.dart';

class AuthUserServiceMock extends Mock implements IAuthUserService {}

class UserPreferenceRepositoryMock extends Mock
    implements IUserPreferenceRepository {}

class UserPreferenceQuizzRepositoryMock extends Mock
    implements IUserPreferenceQuizzRepository {}

void main() {
  late IAuthUserService authUserService;
  late IUserPreferenceRepository userPreferenceRepository;
  late IUserPreferenceQuizzRepository userPreferenceQuizzRepository;
  const authUser = AuthUser(
    uid: EntityId('uid'),
    email: 'test@gmail.com',
  );
  const userPreference = UserPreference({
    'French': true,
    'Italian': false,
    'Lactose-Free': true,
  });
  final question = UserPreferenceQuestionMultipleChoice(
    title: 'title',
    description: 'description',
    type: UserPreferenceQuestionType.multipleChoice,
    options: const [
      Option(label: 'French', key: 'French'),
      Option(label: 'Lactose-Free', key: 'Lactose-Free'),
      Option(label: 'Italian', key: 'Italian'),
    ],
  );
  final question2 = UserPreferenceQuestionMultipleChoice(
    title: 'title',
    description: 'description',
    type: UserPreferenceQuestionType.multipleChoice,
    options: const [
      Option(label: 'option1', key: 'option1'),
      Option(label: 'option2', key: 'option2'),
      Option(label: 'option3', key: 'option3'),
    ],
  );
  final userPreferenceQuizz = [
    question.copyWith(),
    question2.copyWith(),
  ];
  final newUserPreferenceQuizz = [
    question.copyWith(),
    question2.copyWith(),
  ];
  const appLanguage = AppLanguage.en;

  setUp(() {
    authUserService = AuthUserServiceMock();
    userPreferenceRepository = UserPreferenceRepositoryMock();
    userPreferenceQuizzRepository = UserPreferenceQuizzRepositoryMock();

    newUserPreferenceQuizz[0].answer('French');
    newUserPreferenceQuizz[0].answer('Lactose-Free');

    when(() => authUserService.currentUser).thenAnswer(
      (_) => authUser,
    );
  });

  UserPreferenceUpdateController buildSut() => UserPreferenceUpdateController(
        authUserService,
        userPreferenceRepository,
        userPreferenceQuizzRepository,
        currentUserLanguage: appLanguage,
      );

  blocTest<UserPreferenceUpdateController, UserPreferenceUpdateState>(
    'should be in loading state initially',
    build: () => buildSut(),
    setUp: () {
      when(() => userPreferenceRepository.retrieve(authUser.uid)).thenAnswer(
        (_) => Completer<UserPreference>().future,
      );
    },
    verify: (bloc) => {
      expect(
        bloc.state,
        UserPreferenceUpdateLoading(),
      ),
    },
  );

  blocTest<UserPreferenceUpdateController, UserPreferenceUpdateState>(
    'should load questions with default user preference',
    build: () => buildSut(),
    setUp: () {
      when(() => userPreferenceRepository.retrieve(authUser.uid)).thenAnswer(
        (_) => Future.value(userPreference),
      );

      when(() => userPreferenceQuizzRepository.retrieve(appLanguage))
          .thenAnswer(
        (_) => Future.value(userPreferenceQuizz),
      );
    },
    expect: () => [
      UserPreferenceUpdateLoaded(newUserPreferenceQuizz),
    ],
  );
}
