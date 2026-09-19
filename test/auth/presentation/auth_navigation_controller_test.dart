import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/presentation/auth_navigation_controller.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/user_preference_repository.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/local_storage_repo.dart';

class AuthServiceMock extends Mock implements IAuthUserService {}

class UserPreferenceRepositoryMock extends Mock
    implements IUserPreferenceRepository {}

class LocalStorageRepositoryMock extends Mock
    implements ILocalStorageRepository {}

void main() {
  late IAuthUserService authUserService;
  late ILocalStorageRepository prefs;
  late IUserPreferenceRepository userPreferenceRepository;

  const user = AuthUser(uid: EntityId('uid'), email: 'email@gmail.com');

  setUpAll(() {
    registerFallbackValue(const EntityId('uid'));
  });

  setUp(() {
    authUserService = AuthServiceMock();
    prefs = LocalStorageRepositoryMock();
    userPreferenceRepository = UserPreferenceRepositoryMock();
  });

  AuthNavigationController sut() {
    return AuthNavigationController(
      authUserService,prefs, userPreferenceRepository
    );
  }

  blocTest<AuthNavigationController, AuthNavigationState>(
    'should initialy be loading',
    build: () => sut(),
    setUp: () {
      when(() => authUserService.authStateChanges).thenAnswer(
        (_) => Stream.fromFuture(Completer<AuthUser?>().future),
      );
    },
    verify: (bloc) => expect(bloc.state, AuthNavigationState.loading),
  );

  blocTest<AuthNavigationController, AuthNavigationState>(
    'should be logged Out without seen the onboarding',
    build: () => sut(),
    setUp: () {
      when(() => authUserService.authStateChanges).thenAnswer(
        (_) => Stream.value(null),
      );
      when(() => prefs.getBool(hasSeenOnboardingKey)).thenAnswer((_) async => false);
    },
    expect: () => [AuthNavigationState.loggedOutWithoutSeenTheOnboarding],
  );

    blocTest<AuthNavigationController, AuthNavigationState>(
    'should be logged Out after seen the onboarding',
    build: () => sut(),
    setUp: () {
      when(() => authUserService.authStateChanges).thenAnswer(
        (_) => Stream.value(null),
      );
      when(() => prefs.getBool(hasSeenOnboardingKey)).thenAnswer((_) async => true);
    },
    expect: () => [AuthNavigationState.loggedOutButHasSeenTheOnboarding],
  );

  blocTest<AuthNavigationController, AuthNavigationState>(
    'should be logged In',
    build: () => sut(),
    setUp: () {
      when(() => authUserService.authStateChanges).thenAnswer(
        (_) => Stream.value(user),
      );
      when(() => authUserService.currentUser).thenReturn(user);
      when(() => userPreferenceRepository.retrieve(any())).thenAnswer(
        (_) async => const UserPreference({'vegan': true}),
      );
    },
    expect: () => [AuthNavigationState.loggedIn],
  );

  blocTest<AuthNavigationController, AuthNavigationState>(
    'should be logged In without preferences when the quizz was never saved',
    build: () => sut(),
    setUp: () {
      when(() => authUserService.authStateChanges).thenAnswer(
        (_) => Stream.value(user),
      );
      when(() => authUserService.currentUser).thenReturn(user);
      when(() => userPreferenceRepository.retrieve(any())).thenAnswer(
        (_) async => const UserPreference({}),
      );
    },
    expect: () => [AuthNavigationState.loggedInWithoutPreferences],
  );

  blocTest<AuthNavigationController, AuthNavigationState>(
    'should be logged In once the quizz is saved',
    build: () => sut(),
    setUp: () {
      when(() => authUserService.authStateChanges).thenAnswer(
        (_) => Stream.value(user),
      );
      when(() => authUserService.currentUser).thenReturn(user);
      when(() => userPreferenceRepository.retrieve(any())).thenAnswer(
        (_) async => const UserPreference({}),
      );
    },
    act: (bloc) async {
      await Future<void>.delayed(Duration.zero);
      bloc.preferencesCompleted();
    },
    expect: () => [
      AuthNavigationState.loggedInWithoutPreferences,
      AuthNavigationState.loggedIn,
    ],
  );
}
