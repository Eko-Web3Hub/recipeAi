import 'dart:developer';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';

abstract class DeleteAccountAfterAnLoginState extends Equatable {}

class DeleteAccountAfterAnLoginInitial extends DeleteAccountAfterAnLoginState {
  @override
  List<Object?> get props => [];
}

class DeleteAccountAfterAnLoginSuccess extends DeleteAccountAfterAnLoginState {
  @override
  List<Object?> get props => [];
}

class DeleteAccountAfterAnLoginIncorrectPassword
    extends DeleteAccountAfterAnLoginState {
  @override
  List<Object?> get props => [];
}

class DeleteAccountAfterAnErrorOcured extends DeleteAccountAfterAnLoginState {
  DeleteAccountAfterAnErrorOcured();

  @override
  List<Object?> get props => [];
}

class DeleteAccountAfterAnLoginController
    extends Cubit<DeleteAccountAfterAnLoginState> {
  DeleteAccountAfterAnLoginController(
    this._firebaseAuth,
    this._authUserService,
    this._onMainBtnPressed,
  ) : super(
          DeleteAccountAfterAnLoginInitial(),
        );

  final IFirebaseAuth _firebaseAuth;
  final IAuthUserService _authUserService;
  final Future<void> Function() _onMainBtnPressed;

  Future<void> deleteAccountAfterAReLogin(String password) async {
    try {
      emit(DeleteAccountAfterAnLoginInitial());
      await _firebaseAuth.signInWithEmailAndPassword(
        email: _authUserService.currentUser!.email!,
        password: password,
      );
      await _onMainBtnPressed();

      emit(DeleteAccountAfterAnLoginSuccess());
    } on FirebaseAuthException catch (e) {
      log(e.toString());
      if (e.code == 'invalid-credential') {
        emit(DeleteAccountAfterAnLoginIncorrectPassword());
        return;
      }

      emit(
        DeleteAccountAfterAnErrorOcured(),
      );
    }
  }
}
