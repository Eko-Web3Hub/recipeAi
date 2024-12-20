import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/presentation/auth_navigation_controller.dart';

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

  blocTest(
    'should initialy be loading',
    build: () => sut(),
    setUp: () {
      when(() => authUserService.authStateChanges).thenAnswer(
        (_) => Stream.fromFuture(Completer<User?>().future),
      );
    },
    verify: (bloc) => expect(bloc.state, AuthNavigationState.loading),
  );
}
