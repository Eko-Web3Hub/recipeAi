import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/analytics/analytics_event.dart';
import 'package:recipe_ai/analytics/analytics_repository.dart';
import 'package:recipe_ai/auth/application/auth_service.dart';
import 'package:recipe_ai/auth/application/register_usecase.dart';
import 'package:recipe_ai/auth/presentation/register/register_controller.dart';

class RegisterUsecaseMock extends Mock implements RegisterUsecase {}

class AnalyticsRepositoryMock extends Mock implements IAnalyticsRepository {}

void main() {
  late RegisterUsecase registerUsecase;
  late IAnalyticsRepository analyticsRepository;

  const String email = 'test@gmail.com';
  const String password = 'password';
  const String name = 'test';
  const String errorMessage = 'Register failed';

  RegisterController buildController() {
    return RegisterController(
      registerUsecase,
      analyticsRepository,
    );
  }

  setUpAll(() {
    registerFallbackValue(RegisterFinishEvent());
  });

  setUp(() {
    registerUsecase = RegisterUsecaseMock();
    analyticsRepository = AnalyticsRepositoryMock();
  });

  blocTest<RegisterController, RegisterControllerState?>(
    'should emit RegisterControllerSuccess when register is successful',
    build: () => buildController(),
    setUp: () {
      when(
        () => registerUsecase.register(
          email: email,
          password: password,
          name: name,
        ),
      ).thenAnswer(
        (_) async => true,
      );
      when(
        () => analyticsRepository.logEvent(
          any(),
        ),
      ).thenAnswer(
        (_) => Future.value(),
      );
    },
    act: (bloc) async {
      await pumpEventQueue();
      bloc.register(
        email: email,
        password: password,
        name: name,
      );
    },
    expect: () => <RegisterControllerState?>[
      RegisterControllerSuccess(),
    ],
  );

  blocTest<RegisterController, RegisterControllerState?>(
    'should emit RegisterControllerFailed when register is failed due to AuthException exception',
    build: () => buildController(),
    setUp: () {
      when(
        () => registerUsecase.register(
          email: email,
          password: password,
          name: name,
        ),
      ).thenThrow(
        const AuthException(errorMessage),
      );
    },
    act: (bloc) => bloc.register(
      email: email,
      password: password,
      name: name,
    ),
    expect: () => <RegisterControllerState?>[
      RegisterControllerFailed(
        message: errorMessage,
      ),
    ],
  );

  blocTest<RegisterController, RegisterControllerState?>(
    'should emit RegisterControllerFailed when register is failed due to another exception',
    build: () => buildController(),
    setUp: () {
      when(
        () => registerUsecase.register(
          email: email,
          password: password,
          name: name,
        ),
      ).thenThrow(
        Exception(errorMessage),
      );
    },
    act: (bloc) => bloc.register(
      email: email,
      password: password,
      name: name,
    ),
    expect: () => <RegisterControllerState?>[
      RegisterControllerFailed(
        message: registerFailedCodeError,
      ),
    ],
  );
}
