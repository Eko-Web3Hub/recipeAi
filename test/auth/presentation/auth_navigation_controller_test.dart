import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/presentation/auth_navigation_controller.dart';
import 'package:recipe_ai/ddd/entity.dart';

class AuthServiceMock extends Mock implements IAuthUserService {}

void main() {
  late IAuthUserService authUserService;

  setUp(() {
    authUserService = AuthServiceMock();
  });

  AuthNavigationController sut() {
    return AuthNavigationController(
      authUserService,
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
    'should be logged Out',
    build: () => sut(),
    setUp: () {
      when(() => authUserService.authStateChanges).thenAnswer(
        (_) => Stream.value(null),
      );
    },
    expect: () => [AuthNavigationState.loggedOut],
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
