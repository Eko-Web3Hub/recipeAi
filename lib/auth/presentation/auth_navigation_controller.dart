import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';

enum AuthNavigationState {
  loading,
  loggedIn,
  loggedOut,
}

class AuthNavigationController extends Cubit<AuthNavigationState> {
  AuthNavigationController(
    this._authUserService,
  ) : super(AuthNavigationState.loading) {
    _load();
  }

  final IAuthUserService _authUserService;

  void _load() {
    authStateChangeSubscription = _authUserService.authStateChanges.listen(
      (user) {
        if (user != null) {
          emit(AuthNavigationState.loggedIn);
        } else {
          emit(AuthNavigationState.loggedOut);
        }
      },
    );
  }

  @override
  Future<void> close() {
    authStateChangeSubscription?.cancel();
    return super.close();
  }

  StreamSubscription<User?>? authStateChangeSubscription;
}
