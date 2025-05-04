import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/utils/safe_emit.dart';

abstract class ChangePasswordState {}

class ChangePasswordLoading extends ChangePasswordState {}

class ChangePasswordSuccess extends ChangePasswordState {}

class ChangePasswordError extends ChangePasswordState {}

class ChangePasswordController extends Cubit<ChangePasswordState?> {
  ChangePasswordController(
    this._firebaseAuth,
    this._authUserService,
  ) : super(null);

  void changePassword() async {
    safeEmit(ChangePasswordLoading());
    final email = _authUserService.currentUser!.email;

    await _firebaseAuth.sendPasswordResetEmail(email!);
    safeEmit(ChangePasswordSuccess());
  }

  final IFirebaseAuth _firebaseAuth;
  final IAuthUserService _authUserService;
}
