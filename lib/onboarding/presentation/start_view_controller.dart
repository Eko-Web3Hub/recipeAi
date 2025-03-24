import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/analytics/analytics_event.dart';
import 'package:recipe_ai/analytics/analytics_repository.dart';
import 'package:recipe_ai/auth/application/auth_service.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';

abstract class StartViewState extends Equatable {}

class StartViewLoading extends StartViewState {
  @override
  List<Object?> get props => [];
}

class StartViewSuccess extends StartViewState {
  @override
  List<Object?> get props => [];
}

class StartViewError extends StartViewState {
  final String? message;

  StartViewError({
    required this.message,
  });
  
  @override
  List<Object?> get props => [message];
}

class StartViewController extends Cubit<StartViewState?> {
  StartViewController(
    this._authService,
    this._analyticsRepository,
  ) : super(null);

  final IAuthService _authService;
  final IAnalyticsRepository _analyticsRepository;

  Future<void> googleSignIn() async {
    try {
      final result = await _authService.googleSignIn();
      if (result) {
        _analyticsRepository.logEvent(
          LoginFinishEvent(),
        );
        emit(StartViewSuccess());
      }
    } on AuthException catch (e) {
      emit(
        StartViewError(
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
        emit(StartViewSuccess());
      } else {
        emit(StartViewError(
            message:
                di<TranslationController>().currentLanguage.requestCanceled));
      }
    } on AuthException catch (e) {
      emit(
        StartViewError(
          message: e.message,
        ),
      );
    }
  }


}
