import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_service.dart';

abstract class LoginViewState {}

class LoginViewInitial extends LoginViewState {}

class LoginViewLoading extends LoginViewState {}

class LoginViewSuccess extends LoginViewState {}

class LoginViewError extends LoginViewState {
  final String? message;

  LoginViewError({
    required this.message,
  });
}

class LoginViewController extends Cubit<LoginViewState> {
  LoginViewController(
    this._authService,
  ) : super(LoginViewInitial());

  final IAuthService _authService;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(LoginViewLoading());
    try {
      final result = await _authService.login(
        email: email,
        password: password,
      );
      if (result) {
        emit(LoginViewSuccess());
      }
    } on AuthException catch (e) {
      emit(
        LoginViewError(
          message: e.message,
        ),
      );
    }
  }
}
