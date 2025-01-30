import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_ai/user_account/presentation/reset_password_controller.dart';

void main() {
  blocTest<ResetPasswordController, ResetPasswordState>(
    'should be in initial state',
    build: () => ResetPasswordController(),
    verify: (bloc) => expect(
      bloc.state,
      ResetPasswordInitial(),
    ),
  );
}
