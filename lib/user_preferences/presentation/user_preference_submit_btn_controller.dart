import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference_question.dart';

import '../application/user_preference_service.dart';

abstract class UserPreferenceSubmitBtnState extends Equatable {}

class UserPreferenceSubmitBtnInitial extends UserPreferenceSubmitBtnState {
  @override
  List<Object?> get props => [];
}

class UserPreferenceSubmitBtnLoading extends UserPreferenceSubmitBtnState {
  @override
  List<Object?> get props => [];
}

class UserPreferenceSubmitBtnSuccess extends UserPreferenceSubmitBtnState {
  @override
  List<Object?> get props => [];
}

class UserPreferenceSubmitBtnError extends UserPreferenceSubmitBtnState {
  @override
  List<Object?> get props => [];
}

class UserPreferenceSubmitBtnController
    extends Cubit<UserPreferenceSubmitBtnState> {
  UserPreferenceSubmitBtnController(
    this._userPreferenceService,
    this._authUserService, {
    this.seconds,
  }) : super(
          UserPreferenceSubmitBtnInitial(),
        );

  final UserPreferenceService _userPreferenceService;
  final IAuthUserService _authUserService;

  void submit(List<UserPreferenceQuestion> questions) async {
    emit(UserPreferenceSubmitBtnLoading());
    try {
      final uid = _authUserService.currentUser!.uid;
      var prefences = <String, dynamic>{};

      for (final question in questions) {
        final preference = question.toJson();

        prefences = {
          ...preference,
          ...prefences,
        };
      }
      await Future.delayed(Duration(seconds: seconds ?? 3));
      await _userPreferenceService.saveUserPreference(
        uid,
        UserPreference(prefences),
      );
      emit(UserPreferenceSubmitBtnSuccess());
    } catch (e) {
      emit(UserPreferenceSubmitBtnError());
    }
  }

  /// Using for testing
  final int? seconds;
}
