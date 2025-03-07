import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/auth/application/auth_service.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/utils/constant.dart';

class FirebaseAuth extends Mock implements IFirebaseAuth {}

void main() {
  late IFirebaseAuth firebaseAuth;
  const email = "test@gmail.com";
  const password = "password";

  setUp(() {
    firebaseAuth = FirebaseAuth();
  });

  group(
    'login methods',
    () {
      test(
        'should login the user',
        () async {
          when(() => firebaseAuth.signInWithEmailAndPassword(
                email: email,
                password: password,
              )).thenAnswer(
            (_) => Future.value(),
          );
          final sut = AuthService(firebaseAuth);

          final result = await sut.login(
            email: email,
            password: password,
          );

          expect(result, true);
        },
      );

      test(
        'should throw an exception when login fails',
        () async {
          when(() => firebaseAuth.signInWithEmailAndPassword(
                email: email,
                password: password,
              )).thenThrow(
            FirebaseAuthException(
              code: 'code',
              message: 'message',
            ),
          );
          final sut = AuthService(firebaseAuth);

          expect(
            () async => await sut.login(
              email: email,
              password: password,
            ),
            throwsA(isA<AuthException>()),
          );
        },
      );
    },
  );

  group(
    'register methods',
    () {
      test(
        'should register the user',
        () async {
          when(() => firebaseAuth.createUserWithEmailAndPassword(
                email: email,
                password: password,
              )).thenAnswer(
            (_) => Future.value(),
          );
          final sut = AuthService(firebaseAuth);

          final result = await sut.register(
            email: email,
            password: password,
          );

          expect(result, true);
        },
      );

      test(
        'should throw an exception when register fails',
        () async {
          when(() => firebaseAuth.createUserWithEmailAndPassword(
                email: email,
                password: password,
              )).thenThrow(
            FirebaseAuthException(
              code: "error",
              message: "error",
            ),
          );
          final sut = AuthService(firebaseAuth);

          expect(
            () async => await sut.register(
              email: email,
              password: password,
            ),
            throwsA(isA<AuthException>()),
          );
        },
      );
    },
  );

  group(
    'signOut methods',
    () {
      test(
        'should sign out the user',
        () async {
          when(() => firebaseAuth.signOut()).thenAnswer(
            (_) => Future.value(),
          );
          final sut = AuthService(firebaseAuth);

          await sut.signOut();

          verify(() => firebaseAuth.signOut()).called(1);
        },
      );
    },
  );

  group(
    'sendPasswordResetEmail methods',
    () {
      test(
        'should send password reset email',
        () async {
          when(() => firebaseAuth.sendPasswordResetEmail(email)).thenAnswer(
            (_) => Future.value(),
          );
          final sut = AuthService(firebaseAuth);

          await sut.sendPasswordResetEmail(email: email);

          verify(() => firebaseAuth.sendPasswordResetEmail(email)).called(1);
        },
      );

      test(
        'should throw an exception when sending password reset email fails with an invalid email',
        () async {
          when(() => firebaseAuth.sendPasswordResetEmail(email)).thenThrow(
            FirebaseAuthException(
              code: 'invalid-email',
              message: 'message',
            ),
          );
          final sut = AuthService(firebaseAuth);

          try {
            await sut.sendPasswordResetEmail(email: email);
          } catch (e) {
            expect(
              e,
              AuthException(
                AuthError.userNotFound.name,
              ),
            );
          }
        },
      );

      test(
        'should throw an exception when sending password reset email fails with an user not found',
        () async {
          when(() => firebaseAuth.sendPasswordResetEmail(email)).thenThrow(
            FirebaseAuthException(
              code: 'user-not-found',
              message: 'message',
            ),
          );
          final sut = AuthService(firebaseAuth);

          try {
            await sut.sendPasswordResetEmail(email: email);
          } catch (e) {
            expect(
              e,
              AuthException(
                AuthError.userNotFound.name,
              ),
            );
          }
        },
      );

      test(
        'should throw an exception when sending password reset email fails',
        () async {
          when(() => firebaseAuth.sendPasswordResetEmail(email)).thenThrow(
            FirebaseAuthException(
              code: 'code',
              message: 'message',
            ),
          );
          final sut = AuthService(firebaseAuth);

          try {
            await sut.sendPasswordResetEmail(email: email);
          } catch (e) {
            expect(
              e,
              AuthException(
                AuthError.somethingWentWrong.name,
              ),
            );
          }
        },
      );
    },
  );
}
