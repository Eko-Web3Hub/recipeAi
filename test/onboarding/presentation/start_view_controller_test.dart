import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/analytics/analytics_event.dart';
import 'package:recipe_ai/analytics/analytics_repository.dart';
import 'package:recipe_ai/auth/application/auth_service.dart';
import 'package:recipe_ai/onboarding/presentation/start_view_controller.dart';

class AuthServiceMock extends Mock implements IAuthService {}

class AnalyticsRepositoryMock extends Mock implements IAnalyticsRepository {}

void main() {
  late IAnalyticsRepository analyticsRepository;
  late IAuthService authService;
    const String errorMessage = 'Login failed';



    StartViewController buildController() {
    return StartViewController(
      authService,
      analyticsRepository,
    );
  }

  setUp(() {
    authService = AuthServiceMock();
    analyticsRepository = AnalyticsRepositoryMock();
  });


 setUpAll(() {
    registerFallbackValue(LoginFinishEvent());
  });

   blocTest<StartViewController, StartViewState?>(
    'should emit StartViewSuccess when google sign in is successful',
    build: () => buildController(),
    setUp: () {
      when(
        () => authService.googleSignIn(
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
      bloc.googleSignIn();
    },
    expect: () => <StartViewState?>[
      StartViewSuccess(),
    ],
  );

   blocTest<StartViewController, StartViewState?>(
    'should emit StartError when google signin is failed due to another exception',
    build: () => buildController(),
    setUp: () {
      when(
        () => authService.googleSignIn(),
      ).thenThrow(
        const AuthException(errorMessage),
      );
    },
    act: (bloc) => bloc.googleSignIn(),
    expect: () => <StartViewState?>[
      StartViewError(
        message: errorMessage,
      ),
    ],
  );


   blocTest<StartViewController, StartViewState?>(
    'should emit StartViewSuccess when apple sign in is successful',
    build: () => buildController(),
    setUp: () {
      when(
        () => authService.appleSignIn(
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
      bloc.appleSignIn();
    },
    expect: () => <StartViewState?>[
      StartViewSuccess(),
    ],
  );

    blocTest<StartViewController, StartViewState?>(
    'should emit StartError when apple signin is failed due to another exception',
    build: () => buildController(),
    setUp: () {
      when(
        () => authService.appleSignIn(),
      ).thenThrow(
        const AuthException(errorMessage),
      );
    },
    act: (bloc) => bloc.appleSignIn(),
    expect: () => <StartViewState?>[
      StartViewError(
        message: errorMessage,
      ),
    ],
  );


 
}
