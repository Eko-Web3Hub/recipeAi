import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_service.dart';
import 'package:recipe_ai/utils/safe_emit.dart';

abstract class ChangeEmailState {}

class ChangeEmailLoading extends ChangeEmailState {}

class ChangeEmailSuccess extends ChangeEmailState {}

class ChangeEmailRequiredRecentLogin extends ChangeEmailState {}

class ChangeEmailController extends Cubit<ChangeEmailState?> {
  ChangeEmailController(
    this._authService,
  ) : super(null);

  void changeEmail(String email) async {
    try {
      safeEmit(ChangeEmailLoading());
      await _authService.changeEmail(email);
      safeEmit(ChangeEmailSuccess());
      safeEmit(null);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        safeEmit(ChangeEmailRequiredRecentLogin());
        safeEmit(null);

        return;
      }
    }
  }

  final IAuthService _authService;
}
