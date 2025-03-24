import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/local_storage_repo.dart';

enum AuthNavigationState {
  loading,
  loggedIn,
  loggedOutButHasSeenTheOnboarding,
  loggedOutWithoutSeenTheOnboarding
}

class AuthNavigationController extends Cubit<AuthNavigationState> {
  AuthNavigationController(
    this._authUserService,
    this._prefs,
  ) : super(AuthNavigationState.loading) {
    _load();
  }

  final IAuthUserService _authUserService;

  void _load()  {
    authStateChangeSubscription = _authUserService.authStateChanges.listen(
      (user) async {
        if (user != null) {
          emit(AuthNavigationState.loggedIn);
        } else {
          final hasSeenTheOnboarding = (await _prefs.getBool(hasSeenOnboardingKey)) ?? false;
          if (hasSeenTheOnboarding) {
            emit(AuthNavigationState.loggedOutButHasSeenTheOnboarding);
          } else {
              emit(AuthNavigationState.loggedOutWithoutSeenTheOnboarding);
          }
          
        }
      },
    );
  }

  @override
  Future<void> close() {
    authStateChangeSubscription?.cancel();
    return super.close();
  }

  StreamSubscription<AuthUser?>? authStateChangeSubscription;
  final ILocalStorageRepository _prefs;
}
