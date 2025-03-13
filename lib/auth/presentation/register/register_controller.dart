import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/analytics/analytics_event.dart';
import 'package:recipe_ai/analytics/analytics_repository.dart';
import 'package:recipe_ai/auth/application/auth_service.dart';
import 'package:recipe_ai/auth/application/register_usecase.dart';

abstract class RegisterControllerState extends Equatable {}

class RegisterControllerSuccess extends RegisterControllerState {
  @override
  List<Object?> get props => [];
}

class RegisterControllerFailed extends RegisterControllerState {
  final String? message;

  RegisterControllerFailed({
    required this.message,
  });
  @override
  List<Object?> get props => [message];
}

class RegisterController extends Cubit<RegisterControllerState?> {
  RegisterController(
    this._registerUsecase,
    this._analyticsRepository,
  ) : super(null);

  final RegisterUsecase _registerUsecase;
  final IAnalyticsRepository _analyticsRepository;

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final result = await _registerUsecase.register(
        email: email,
        password: password,
        name: name,
      );

      if (result) {
        _analyticsRepository.logEvent(
          RegisterFinishEvent(),
        );
        emit(
          RegisterControllerSuccess(),
        );
        return;
      }
    } on AuthException catch (e) {
      emit(
        RegisterControllerFailed(
          message: e.message,
        ),
      );
    } on Exception catch (_) {
      emit(
        RegisterControllerFailed(
          message: registerFailedCodeError,
        ),
      );
    }
  }
}

const registerFailedCodeError = 'registerFailed';
