import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';

abstract class DeleteAccountState extends Equatable {}

class DeleteAccountInitial extends DeleteAccountState {
  @override
  List<Object?> get props => [];
}

class DeleteAccountSuccess extends DeleteAccountState {
  @override
  List<Object?> get props => [];
}

class DeleteAccountRequiredRecentLogin extends DeleteAccountState {
  @override
  List<Object?> get props => [];
}

class DeleteAccountErrorOcuured extends DeleteAccountState {
  DeleteAccountErrorOcuured();

  @override
  List<Object?> get props => [];
}

class DeleteAccountController extends Cubit<DeleteAccountState> {
  DeleteAccountController(
    this._firebaseAuth,
  ) : super(DeleteAccountInitial());

  final IFirebaseAuth _firebaseAuth;

  Future<void> deleteAccount() async {
    try {
      await _firebaseAuth.deleteAccount();

      emit(DeleteAccountSuccess());
    } on FirebaseAuthException catch (e) {
      log(e.toString());
      if (e.code == 'requires-recent-login') {
        emit(DeleteAccountRequiredRecentLogin());
        emit(DeleteAccountInitial());
        return;
      }

      emit(
        DeleteAccountErrorOcuured(),
      );
    }
  }
}
