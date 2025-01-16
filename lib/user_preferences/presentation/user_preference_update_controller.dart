import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/user_preference_repository.dart';

abstract class UserPreferenceUpdateState extends Equatable {}

class UserPreferenceUpdateLoading extends UserPreferenceUpdateState {
  @override
  List<Object?> get props => [];
}

class UserPreferenceUpdateLoaded extends UserPreferenceUpdateState {
  UserPreferenceUpdateLoaded(
    this.userPreference,
  );

  final UserPreference userPreference;

  @override
  List<Object?> get props => [userPreference];
}

class UserPreferenceUpdateController extends Cubit<UserPreferenceUpdateState> {
  UserPreferenceUpdateController(
    this._authUserService,
    this._userPreferenceRepository,
  ) : super(
          UserPreferenceUpdateLoading(),
        ) {
    _load();
  }

  Future<void> _load() async {
    final uid = _authUserService.currentUser!.uid;
    final userPreference = await _userPreferenceRepository.retrieve(uid);
    emit(UserPreferenceUpdateLoaded(userPreference));
  }

  final IAuthUserService _authUserService;
  final IUserPreferenceRepository _userPreferenceRepository;
}
