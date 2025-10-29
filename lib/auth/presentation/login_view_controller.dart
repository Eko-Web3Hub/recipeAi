import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/analytics/analytics_event.dart';
import 'package:recipe_ai/analytics/analytics_repository.dart';
import 'package:recipe_ai/auth/application/auth_service.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/user_preference_repository.dart';

abstract class LoginViewState {}

class LoginViewInitial extends LoginViewState {}

class LoginViewLoading extends LoginViewState {}

class LoginViewSuccess extends LoginViewState {}

class EmptyUserPrefs extends LoginViewState {}

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
    this._userPreferenceRepository,
    this._authUserService,
  ) : super(LoginViewInitial());

  final IAuthService _authService;
  final IAnalyticsRepository _analyticsRepository;
  final IUserPreferenceRepository _userPreferenceRepository;
  final IAuthUserService _authUserService;

  Future<void> googleSignIn() async {
    try {
      final result = await _authService.googleSignIn();
      if (result) {
        _analyticsRepository.logEvent(
          LoginFinishEvent(),
        );
        checkUserPrefs();
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
        checkUserPrefs();
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

  Future<void> checkUserPrefs() async {
    try {
      final uid = _authUserService.currentUser!.uid;
      final userPreference = await _userPreferenceRepository.retrieve(uid);

      if (userPreference.preferences.isEmpty) {
        emit(EmptyUserPrefs());
      } else {
        emit(LoginViewSuccess());
      }
    } catch (_) {
      //
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

        checkUserPrefs();
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
