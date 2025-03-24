import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/presentation/auth_navigation_controller.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/local_storage_repo.dart';

class AuthServiceMock extends Mock implements IAuthUserService {}

class LocalStorageRepositoryMock extends Mock
    implements ILocalStorageRepository {}

void main() {
  late IAuthUserService authUserService;
  late ILocalStorageRepository prefs;

  setUp(() {
    authUserService = AuthServiceMock();
    prefs = LocalStorageRepositoryMock();
  });

  AuthNavigationController sut() {
    return AuthNavigationController(
      authUserService,prefs
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
        (_) => Stream.value(
          const AuthUser(
            uid: EntityId('uid'),
            email: 'email@gmail.com',
          ),
        ),
      );
    },
    expect: () => [AuthNavigationState.loggedIn],
  );
}
