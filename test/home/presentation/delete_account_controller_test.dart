import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/home/presentation/delete_account_controller.dart';
import 'package:recipe_ai/utils/app_text.dart';

class AuthUserServiceMock extends Mock implements IAuthUserService {}

class FirebaseAuthMock extends Mock implements IFirebaseAuth {}

void main() {
  late IFirebaseAuth firebaseAuth;
  late IAuthUserService authUserService;

  setUp(() {
    authUserService = AuthUserServiceMock();
    firebaseAuth = FirebaseAuthMock();
  });

  DeleteAccountController buildSut() {
    return DeleteAccountController(
      authUserService,
      firebaseAuth,
    );
  }

  blocTest<DeleteAccountController, DeleteAccountState>(
    'should be in initial state',
    build: () => buildSut(),
    verify: (bloc) {
      expect(bloc.state, DeleteAccountInitial());
    },
  );

  blocTest<DeleteAccountController, DeleteAccountState>(
    'should delete account',
    build: () => buildSut(),
    act: (bloc) => bloc.deleteAccount(),
    setUp: () {
      when(() => firebaseAuth.deleteAccount())
          .thenAnswer((_) => Future.value());
    },
    verify: (bloc) => expect(
      bloc.state,
      DeleteAccountSuccess(),
    ),
  );

  blocTest<DeleteAccountController, DeleteAccountState>(
    'should fail to delete account when requires recent login',
    build: () => buildSut(),
    act: (bloc) => bloc.deleteAccount(),
    setUp: () {
      when(() => firebaseAuth.deleteAccount()).thenThrow(FirebaseAuthException(
        code: 'requires-recent-login',
        message: 'requires-recent-login',
      ));
    },
    expect: () => [
      DeleteAccountRequiredRecentLogin(),
    ],
  );

  blocTest<DeleteAccountController, DeleteAccountState>(
    'should fail to delete account when an error occurs',
    build: () => buildSut(),
    act: (bloc) => bloc.deleteAccount(),
    setUp: () {
      when(() => firebaseAuth.deleteAccount()).thenThrow(FirebaseAuthException(
        code: 'any-error',
        message: 'any-error',
      ));
    },
    expect: () => [
      DeleteAccountErrorOcuured(
        AppText.deleteAccountError,
      ),
    ],
  );

  group('deleteAccountAfterAReLogin method', () {
    const password = 'password';
    const authUser = AuthUser(
      uid: EntityId('uid'),
      email: 'test@gmail.com',
    );

    blocTest<DeleteAccountController, DeleteAccountState>(
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
        DeleteAccountSuccess(),
      ],
    );

    blocTest<DeleteAccountController, DeleteAccountState>(
      'should fail to delete account after a re-login when an error occurs',
      build: () => buildSut(),
      act: (bloc) => bloc.deleteAccountAfterAReLogin(password),
      setUp: () {
        when(() => authUserService.currentUser).thenReturn(authUser);
        when(() => firebaseAuth.signInWithEmailAndPassword(
              email: authUser.email!,
              password: password,
            )).thenAnswer((_) => Future.value());
        when(() => firebaseAuth.deleteAccount())
            .thenThrow(FirebaseAuthException(
          code: 'any-error',
          message: 'any-error',
        ));
      },
      expect: () => [
        DeleteAccountErrorOcuured(
          AppText.deleteAccountError,
        ),
      ],
    );
  });
}
