import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/auth/application/auth_service.dart';
import 'package:recipe_ai/user_account/presentation/reset_password_controller.dart';

class AuthServiceMock extends Mock implements IAuthService {}

void main() {
  late IAuthService authService;
  const email = 'test@gmail.com';

  setUp(() {
    authService = AuthServiceMock();
  });

  blocTest<ResetPasswordController, ResetPasswordState>(
    'should be in initial state',
    build: () => ResetPasswordController(
      authService,
    ),
    verify: (bloc) => expect(
      bloc.state,
      ResetPasswordInitial(),
    ),
  );

  blocTest<ResetPasswordController, ResetPasswordState>(
    'should be loading state',
    build: () => ResetPasswordController(
      authService,
    ),
    setUp: () =>
        when(() => authService.sendPasswordResetEmail(email: email)).thenAnswer(
      (_) async => Completer<bool>().future,
    ),
    act: (bloc) async {
      await pumpEventQueue();
      bloc.resetPassword(email);
    },
    verify: (bloc) => expect(
      bloc.state,
      ResetPasswordLoading(),
    ),
  );

  blocTest<ResetPasswordController, ResetPasswordState>(
    'should send password reset email',
    build: () => ResetPasswordController(
      authService,
    ),
    setUp: () {
      when(() => authService.sendPasswordResetEmail(email: email))
          .thenAnswer((_) async => true);
    },
    act: (bloc) => bloc.resetPassword(email),
    expect: () => [
      ResetPasswordLoading(),
      ResetPasswordSuccess(),
    ],
  );

  blocTest<ResetPasswordController, ResetPasswordState>(
    'should show error message when sending password reset email fails',
    build: () => ResetPasswordController(
      authService,
    ),
    setUp: () {
      when(() => authService.sendPasswordResetEmail(email: email))
          .thenThrow(const AuthException('Error'));
    },
    act: (bloc) => bloc.resetPassword(email),
    expect: () => [
      ResetPasswordLoading(),
      ResetPasswordFailure('Error'),
    ],
  );
}
