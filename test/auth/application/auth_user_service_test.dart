import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/analytics/analytics_repository.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';

class FirebaseAuthMock extends Mock implements IFirebaseAuth {}

class AnalyticsRepositoryMock extends Mock implements IAnalyticsRepository {}

class FakeUser extends Mock implements User {}

void main() {
  late IFirebaseAuth firebaseAuth;
  late User user;
  late IAnalyticsRepository analyticsRepository;
  const currentUser = AuthUser(
    uid: EntityId('uid'),
    email: 'email@gmail.com',
  );

  setUp(() {
    firebaseAuth = FirebaseAuthMock();
    user = FakeUser();
    analyticsRepository = AnalyticsRepositoryMock();

    when(
      () => analyticsRepository.setUserId(currentUser.uid.value),
    ).thenAnswer((_) => Future.value());
    when(
      () => analyticsRepository.setUserId(''),
    ).thenAnswer((_) => Future.value());
  });

  void whenCurrentUserIsAuthenticated() {
    when(() => firebaseAuth.currentUser!).thenReturn(user);
    when(() => user.uid).thenReturn(currentUser.uid.value);
    when(() => user.email).thenReturn(currentUser.email);
  }

  group(
    'when the auth state changes',
    () {
      test(
        'should return null if the user is not authenticated',
        () async {
          when(() => firebaseAuth.authStateChanges)
              .thenAnswer((_) => Stream.value(null));

          final authUserService =
              AuthUserService(firebaseAuth, analyticsRepository);

          final response = await authUserService.authStateChanges.first;

          expect(response, null);
        },
      );

      test(
        'should return the current user if the user is authenticated',
        () async {
          whenCurrentUserIsAuthenticated();

          when(() => firebaseAuth.authStateChanges)
              .thenAnswer((_) => Stream.value(user));

          final authUserService = AuthUserService(
            firebaseAuth,
            analyticsRepository,
          );

          final response = await authUserService.authStateChanges.first;

          expect(
            response,
            currentUser,
          );
        },
      );
    },
  );

  group(
    'when the current user is requested',
    () {
      test(
        'should return null if the user is not authenticated',
        () {
          when(() => firebaseAuth.currentUser).thenReturn(null);

          final authUserService = AuthUserService(
            firebaseAuth,
            analyticsRepository,
          );

          final response = authUserService.currentUser;

          expect(response, null);
        },
      );

      test(
        'should return the current user if the user is authenticated',
        () {
          whenCurrentUserIsAuthenticated();

          final authUserService =
              AuthUserService(firebaseAuth, analyticsRepository);

          final response = authUserService.currentUser;

          expect(
            response,
            currentUser,
          );
        },
      );
    },
  );
}
