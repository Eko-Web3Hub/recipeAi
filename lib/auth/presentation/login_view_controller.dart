import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/analytics/analytics_event.dart';
import 'package:recipe_ai/analytics/analytics_repository.dart';
import 'package:recipe_ai/auth/application/auth_service.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';

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
    this._analyticsRepository,
  ) : super(LoginViewInitial());

  final IAuthService _authService;
  final IAnalyticsRepository _analyticsRepository;

  Future<void> googleSignIn() async {
    try {
      final result = await _authService.googleSignIn();
      if (result) {
        _analyticsRepository.logEvent(
          LoginFinishEvent(),
        );
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

  Future<void> appleSignIn() async {
    try {
      final result = await _authService.appleSignIn();
      if (result) {
        _analyticsRepository.logEvent(
          LoginFinishEvent(),
        );
        emit(LoginViewSuccess());
      } else {
        emit(LoginViewError(
            message:
                di<TranslationController>().currentLanguage.requestCanceled));
      }
    } on AuthException catch (e) {
      emit(
        LoginViewError(
          message: e.message,
        ),
      );
    }
  }

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
        _analyticsRepository.logEvent(
          LoginFinishEvent(),
        );
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
