import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/application/user_personnal_info_service.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/receipe/application/user_recipe_service.dart';
import 'package:recipe_ai/user_preferences/domain/model/onboarding_step.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/onboarding_quizz_repository.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/user_preference_repository.dart';
import 'package:recipe_ai/utils/safe_emit.dart';

class ProfileState extends Equatable {
  const ProfileState({
    this.name,
    this.preferences,
    this.steps = const [],
    this.generatedCount,
    this.favoriteCount,
  });

  final String? name;

  /// With [steps], gives the diet and chronic disease badges.
  final UserPreference? preferences;
  final List<OnboardingStep> steps;

  /// Null while loading or when the count could not be read.
  final int? generatedCount;
  final int? favoriteCount;

  ProfileState copyWith({
    String? name,
    UserPreference? preferences,
    List<OnboardingStep>? steps,
    int? generatedCount,
    int? favoriteCount,
  }) => ProfileState(
    name: name ?? this.name,
    preferences: preferences ?? this.preferences,
    steps: steps ?? this.steps,
    generatedCount: generatedCount ?? this.generatedCount,
    favoriteCount: favoriteCount ?? this.favoriteCount,
  );

  @override
  List<Object?> get props => [
    name,
    preferences?.preferences,
    steps,
    generatedCount,
    favoriteCount,
  ];
}

/// Profile header: name, diet badges, generated and favorite recipe counts.
///
/// The name and the favorites are watched; the preferences and the generated
/// count are read once and again on [refresh], since they change on other
/// screens.
class ProfileController extends Cubit<ProfileState> {
  ProfileController(
    this._authUserService,
    this._userPersonnalInfoService,
    this._userPreferenceRepository,
    this._onboardingQuizzRepository,
    this._userRecipeService,
  ) : super(const ProfileState()) {
    _watch();
    refresh();
  }

  ProfileController.inject()
    : this(
        di<IAuthUserService>(),
        di<IUserPersonnalInfoService>(),
        di<IUserPreferenceRepository>(),
        di<IOnboardingQuizzRepository>(),
        di<IUserRecipeService>(),
      );

  final IAuthUserService _authUserService;
  final IUserPersonnalInfoService _userPersonnalInfoService;
  final IUserPreferenceRepository _userPreferenceRepository;
  final IOnboardingQuizzRepository _onboardingQuizzRepository;
  final IUserRecipeService _userRecipeService;

  final _subscriptions = <StreamSubscription<dynamic>>[];

  void _watch() {
    _subscriptions
      ..add(
        _userPersonnalInfoService.watch().listen((info) {
          if (info != null) safeEmit(state.copyWith(name: info.name));
        }, onError: (_) {}),
      )
      ..add(
        _userRecipeService.watchAllSavedReceipes().listen(
          (favorites) =>
              safeEmit(state.copyWith(favoriteCount: favorites.length)),
          onError: (_) {},
        ),
      );
  }

  Future<void> refresh() => (_loadPreferences(), _loadGeneratedCount()).wait;

  Future<void> _loadPreferences() async {
    final user = _authUserService.currentUser;
    if (user == null) return;
    try {
      final (preferences, steps) = await (
        _userPreferenceRepository.retrieve(user.uid),
        _onboardingQuizzRepository.retrieve(),
      ).wait;
      safeEmit(state.copyWith(preferences: preferences, steps: steps));
    } catch (_) {
      // The profile simply shows no badge.
    }
  }

  Future<void> _loadGeneratedCount() async {
    try {
      final count = await _userRecipeService.countGeneratedRecipes();
      safeEmit(state.copyWith(generatedCount: count));
    } catch (_) {
      // The stat keeps its last known value.
    }
  }

  @override
  Future<void> close() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    return super.close();
  }
}
