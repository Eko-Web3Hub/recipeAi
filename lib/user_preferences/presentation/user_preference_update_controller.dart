import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/user_preferences/domain/model/onboarding_answers.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/user_preference_repository.dart';
import 'package:recipe_ai/user_preferences/presentation/onboarding_preference_mapper.dart';
import 'package:recipe_ai/utils/safe_emit.dart';

abstract class UserPreferenceUpdateState extends Equatable {
  const UserPreferenceUpdateState();
}

class UserPreferenceUpdateLoading extends UserPreferenceUpdateState {
  const UserPreferenceUpdateLoading();

  @override
  List<Object?> get props => [];
}

class UserPreferenceUpdateLoaded extends UserPreferenceUpdateState {
  const UserPreferenceUpdateLoaded(this.answers);

  final OnboardingAnswers answers;

  @override
  List<Object?> get props => [answers];
}

/// Loads the saved preferences and turns them back into onboarding answers, so
/// the profile screen shows the same questions as the onboarding, pre-filled.
class UserPreferenceUpdateController extends Cubit<UserPreferenceUpdateState> {
  UserPreferenceUpdateController(
    this._authUserService,
    this._userPreferenceRepository,
  ) : super(const UserPreferenceUpdateLoading()) {
    _load();
  }

  Future<void> _load() async {
    final uid = _authUserService.currentUser!.uid;
    final userPreference = await _userPreferenceRepository.retrieve(uid);

    safeEmit(UserPreferenceUpdateLoaded(answersFrom(userPreference)));
  }

  final IAuthUserService _authUserService;
  final IUserPreferenceRepository _userPreferenceRepository;
}
