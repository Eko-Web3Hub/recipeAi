import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_service.dart';

abstract class ResetPasswordState extends Equatable {}

class ResetPasswordInitial extends ResetPasswordState {
  @override
  List<Object> get props => [];
}

class ResetPasswordLoading extends ResetPasswordState {
  @override
  List<Object> get props => [];
}

class ResetPasswordSuccess extends ResetPasswordState {
  @override
  List<Object> get props => [];
}

class ResetPasswordFailure extends ResetPasswordState {
  final String message;

  ResetPasswordFailure(this.message);

  @override
  List<Object> get props => [message];
}

class ResetPasswordController extends Cubit<ResetPasswordState> {
  ResetPasswordController(
    this._authService,
  ) : super(ResetPasswordInitial());

  final IAuthService _authService;

  void resetPassword(String email) async {
    emit(ResetPasswordLoading());
    try {
      final isSuccess = await _authService.sendPasswordResetEmail(email: email);
      if (isSuccess) {
        emit(ResetPasswordSuccess());
      }
    } on AuthException catch (e) {
      emit(
        ResetPasswordFailure(e.message),
      );
    }
  }
}
