import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/auth/application/auth_service.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/application/register_usecase.dart';
import 'package:recipe_ai/auth/domain/model/user_personnal_info.dart';
import 'package:recipe_ai/auth/domain/repositories/user_personnal_info_repository.dart';
import 'package:recipe_ai/ddd/entity.dart';

class AuthService extends Mock implements IAuthService {}

class AuthUserService extends Mock implements IAuthUserService {}

class UserPersonnalInfoRepository extends Mock
    implements IUserPersonnalInfoRepository {}

void main() {
  late IAuthService authService;
  late IAuthUserService authUserService;
  late IUserPersonnalInfoRepository userPersonnalInfoRepository;

  const email = 'test@gmail.com';
  const password = 'password';
  const message = 'Register failed';
  const name = 'test';

  setUp(() {
    authService = AuthService();
    authUserService = AuthUserService();
    userPersonnalInfoRepository = UserPersonnalInfoRepository();
  });

  group(
    'should fail ',
    () {
      test(
        'when user is not authenticated',
        () async {
          final registerUsecase = RegisterUsecase(
            authService,
            authUserService,
            userPersonnalInfoRepository,
          );
          when(
            () => authService.register(
              email: email,
              password: password,
            ),
          ).thenThrow(const AuthException(message));

          try {
            await registerUsecase.register(
              email: email,
              password: password,
              name: name,
            );
          } catch (e) {
            expect(e, isA<AuthException>());
          }
        },
      );

      test(
        'with the right error message when the user is not authenticated',
        () async {
          final registerUsecase = RegisterUsecase(
            authService,
            authUserService,
            userPersonnalInfoRepository,
          );
          when(
            () => authService.register(
              email: email,
              password: password,
            ),
          ).thenAnswer((_) => Future.value(false));
          when(
            () => authUserService.currentUser,
          ).thenReturn(
            null,
          );

          try {
            await registerUsecase.register(
              email: email,
              password: password,
              name: name,
            );
          } catch (e) {
            expect(e, isA<AuthException>());
            expect((e as AuthException).message, 'Register failed');
          }
        },
      );
    },
  );

  test(
    'should register a user',
    () async {
      final registerUsecase = RegisterUsecase(
        authService,
        authUserService,
        userPersonnalInfoRepository,
      );
      const userPersonnalInfo = UserPersonnalInfo(
        uid: EntityId('uid'),
        email: email,
        name: name,
      );

      when(
        () => authService.register(
          email: email,
          password: password,
        ),
      ).thenAnswer((_) => Future.value(true));
      when(
        () => authUserService.currentUser,
      ).thenAnswer(
        (_) => const AuthUser(
          email: email,
          uid: EntityId(
            'uid',
          ),
        ),
      );
      when(
        () => userPersonnalInfoRepository.save(userPersonnalInfo),
      ).thenAnswer(
        (_) => Future.value(),
      );

      final result = await registerUsecase.register(
        email: email,
        password: password,
        name: name,
      );

      verify(
        () => userPersonnalInfoRepository.save(
          userPersonnalInfo,
        ),
      ).called(1);
      expect(result, true);
    },
  );
}
