import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/utils/app_text.dart';

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
  final String message;

  DeleteAccountAfterAnErrorOcured(this.message);

  @override
  List<Object?> get props => [message];
}

class DeleteAccountAfterAnLoginController
    extends Cubit<DeleteAccountAfterAnLoginState> {
  DeleteAccountAfterAnLoginController(
    this._firebaseAuth,
    this._authUserService,
  ) : super(
          DeleteAccountAfterAnLoginInitial(),
        );

  final IFirebaseAuth _firebaseAuth;
  final IAuthUserService _authUserService;

  Future<void> deleteAccountAfterAReLogin(String password) async {
    try {
      emit(DeleteAccountAfterAnLoginInitial());
      await _firebaseAuth.signInWithEmailAndPassword(
        email: _authUserService.currentUser!.email!,
        password: password,
      );
      await _firebaseAuth.deleteAccount();

      emit(DeleteAccountAfterAnLoginSuccess());
    } on FirebaseAuthException catch (e) {
      log(e.toString());
      if (e.code == 'invalid-credential') {
        emit(DeleteAccountAfterAnLoginIncorrectPassword());
        return;
      }

      emit(
        DeleteAccountAfterAnErrorOcured(
          appTexts.deleteAccountError,
        ),
      );
    }
  }
}
