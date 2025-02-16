import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/home/presentation/delete_account_after_an_login.dart';

import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/utils/app_text.dart';

class AuthUserServiceMock extends Mock implements IAuthUserService {}

class FirebaseAuthMock extends Mock implements IFirebaseAuth {}

void main() {
  late IFirebaseAuth firebaseAuth;
  late IAuthUserService authUserService;

  const password = 'password';
  const authUser = AuthUser(
    uid: EntityId('uid'),
    email: 'test@gmail.com',
  );

  setUp(() {
    authUserService = AuthUserServiceMock();
    firebaseAuth = FirebaseAuthMock();
  });

  DeleteAccountAfterAnLoginController buildSut() {
    return DeleteAccountAfterAnLoginController(
      firebaseAuth,
      authUserService,
    );
  }

  blocTest<DeleteAccountAfterAnLoginController, DeleteAccountAfterAnLoginState>(
    'should be in initial state',
    build: () => buildSut(),
    verify: (bloc) {
      expect(bloc.state, DeleteAccountAfterAnLoginInitial());
    },
  );

  blocTest<DeleteAccountAfterAnLoginController, DeleteAccountAfterAnLoginState>(
    'should delete account after a re-login',
    build: () => buildSut(),
    act: (bloc) => bloc.deleteAccountAfterAReLogin(password),
    setUp: () {
      when(() => authUserService.currentUser).thenReturn(authUser);
      when(() => firebaseAuth.signInWithEmailAndPassword(
            email: authUser.email!,
            password: password,
          )).thenAnswer((_) => Future.value());
      when(() => firebaseAuth.deleteAccount())
          .thenAnswer((_) => Future.value());
    },
    verify: (bloc) {
      verify(() => firebaseAuth.signInWithEmailAndPassword(
            email: authUser.email!,
            password: password,
          )).called(1);
      verify(() => firebaseAuth.deleteAccount()).called(1);
    },
    expect: () => [
      DeleteAccountAfterAnLoginInitial(),
      DeleteAccountAfterAnLoginSuccess(),
    ],
  );

  blocTest<DeleteAccountAfterAnLoginController, DeleteAccountAfterAnLoginState>(
    'should fail to delete account after a re-login when an invalid credential occurs',
    build: () => buildSut(),
    act: (bloc) => bloc.deleteAccountAfterAReLogin(password),
    setUp: () {
      when(() => authUserService.currentUser).thenReturn(authUser);
      when(() => firebaseAuth.signInWithEmailAndPassword(
            email: authUser.email!,
            password: password,
          )).thenThrow(
        FirebaseAuthException(code: 'invalid-credential'),
      );
    },
    expect: () => [
      DeleteAccountAfterAnLoginInitial(),
      DeleteAccountAfterAnLoginIncorrectPassword(),
    ],
  );

  blocTest<DeleteAccountAfterAnLoginController, DeleteAccountAfterAnLoginState>(
    'should fail to delete account after a re-login when an error occurs',
    build: () => buildSut(),
    act: (bloc) => bloc.deleteAccountAfterAReLogin(password),
    setUp: () {
      when(() => authUserService.currentUser).thenReturn(authUser);
      when(() => firebaseAuth.signInWithEmailAndPassword(
            email: authUser.email!,
            password: password,
          )).thenAnswer((_) => Future.value());
      when(() => firebaseAuth.deleteAccount()).thenThrow(FirebaseAuthException(
        code: 'any-error',
        message: 'any-error',
      ));
    },
    expect: () => [
      DeleteAccountAfterAnLoginInitial(),
      DeleteAccountAfterAnErrorOcured(
        appTexts.deleteAccountError,
      ),
    ],
  );
}
