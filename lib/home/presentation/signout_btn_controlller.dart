import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_service.dart';

abstract class SignOutBtnState {}

class SignOutBtnInitial extends SignOutBtnState {}

class SignOutBtnLoading extends SignOutBtnState {}

class SignOutBtnSuccess extends SignOutBtnState {}

class SignOutBtnFailed extends SignOutBtnState {
  final String? message;

  SignOutBtnFailed({
    required this.message,
  });
}

class SignOutBtnControlller extends Cubit<SignOutBtnState> {
  SignOutBtnControlller(
    this._authService,
  ) : super(SignOutBtnInitial());

  final IAuthService _authService;

  Future<void> signOut() async {
    emit(SignOutBtnLoading());
    try {
      await _authService.signOut();
      emit(SignOutBtnSuccess());
    } on AuthException catch (e) {
      emit(
        SignOutBtnFailed(
          message: e.message,
        ),
      );
    }
  }
}
