import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/user_preference_repository.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/local_storage_repo.dart';

enum AuthNavigationState {
  loading,
  loggedIn,

  /// Signed in, but the onboarding quizz was never submitted (e.g. the app was
  /// closed right after the sign up).
  loggedInWithoutPreferences,
  loggedOutButHasSeenTheOnboarding,
  loggedOutWithoutSeenTheOnboarding
}

class AuthNavigationController extends Cubit<AuthNavigationState> {
  AuthNavigationController(
    this._authUserService,
    this._prefs,
    this._userPreferenceRepository,
  ) : super(AuthNavigationState.loading) {
    _load();
  }

  final IAuthUserService _authUserService;

  void _load()  {
    authStateChangeSubscription = _authUserService.authStateChanges.listen(
      (user) async {
        if (user != null) {
          final userPreference =
              await _userPreferenceRepository.retrieve(user.uid);
          // The user may have signed out while the preferences were loading.
          if (isClosed || _authUserService.currentUser?.uid != user.uid) {
            return;
          }
          emit(
            userPreference.preferences.isEmpty
                ? AuthNavigationState.loggedInWithoutPreferences
                : AuthNavigationState.loggedIn,
          );
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

  /// Called once the onboarding quizz is saved, to unlock the guarded routes.
  void preferencesCompleted() {
    if (state == AuthNavigationState.loggedInWithoutPreferences) {
      emit(AuthNavigationState.loggedIn);
    }
  }

  @override
  Future<void> close() {
    authStateChangeSubscription?.cancel();
    return super.close();
  }

  StreamSubscription<AuthUser?>? authStateChangeSubscription;
  final ILocalStorageRepository _prefs;
  final IUserPreferenceRepository _userPreferenceRepository;
}
