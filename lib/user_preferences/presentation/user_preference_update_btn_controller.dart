import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/user_preference_repository.dart';

abstract class UserPreferenceUpdateBtnState extends Equatable {}

class UserPreferenceUpdateBtnInitial extends UserPreferenceUpdateBtnState {
  @override
  List<Object?> get props => [];
}

class UserPreferenceUpdateBtnLoading extends UserPreferenceUpdateBtnState {
  @override
  List<Object?> get props => [];
}

class HasNotChangedUserPreference extends UserPreferenceUpdateBtnState {
  @override
  List<Object?> get props => [];
}

class UserPreferenceUpdateBtnController
    extends Cubit<UserPreferenceUpdateBtnState> {
  UserPreferenceUpdateBtnController(
    this._authUserService,
    this._userPreferenceRepository,
  ) : super(
          UserPreferenceUpdateBtnInitial(),
        );

  void update(
    UserPreference newUserPreference,
  ) async {
    emit(UserPreferenceUpdateBtnLoading());
    final uid = _authUserService.currentUser!.uid;
    final oldUserPreference = await _userPreferenceRepository.retrieve(
      uid,
    );
    if (oldUserPreference == newUserPreference) {
      emit(HasNotChangedUserPreference());
      return;
    }
  }

  final IAuthUserService _authUserService;
  final IUserPreferenceRepository _userPreferenceRepository;
}
