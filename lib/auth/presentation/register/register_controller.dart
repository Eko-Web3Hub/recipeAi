import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_service.dart';
import 'package:recipe_ai/auth/application/register_usecase.dart';
import 'package:recipe_ai/utils/app_text.dart';

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
  ) : super(null);

  final RegisterUsecase _registerUsecase;

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
    } catch (e) {
      emit(
        RegisterControllerFailed(
          message: appTexts.registerFailed,
        ),
      );
    }
  }
}
