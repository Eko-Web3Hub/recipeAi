import 'package:bloc_test/bloc_test.dart';
import 'package:recipe_ai/auth/presentation/register/register_controller.dart';

void main() {
  RegisterController buildController() {
    return RegisterController();
  }

  blocTest<RegisterController, RegisterControllerState?>(
    'should emit RegisterControllerSuccess when register is successful',
    build: () => buildController(),
    act: (bloc) => bloc.register(),
    expect: () => <RegisterControllerState?>[RegisterControllerSuccess()],
  );

  blocTest<RegisterController, RegisterControllerState?>(
    'should emit RegisterControllerFailed when register is failed',
    build: () => buildController(),
    act: (bloc) => bloc.register(),
    expect: () => <RegisterControllerState?>[RegisterControllerFailed()],
  );
}
