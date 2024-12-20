import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference_question.dart';

import '../application/user_preference_service.dart';

abstract class UserPreferenceSubmitBtnState {}

class UserPreferenceSubmitBtnInitial extends UserPreferenceSubmitBtnState {}

class UserPreferenceSubmitBtnLoading extends UserPreferenceSubmitBtnState {}

class UserPreferenceSubmitBtnSuccess extends UserPreferenceSubmitBtnState {}

class UserPreferenceSubmitBtnError extends UserPreferenceSubmitBtnState {}

class UserPreferenceSubmitBtnController
    extends Cubit<UserPreferenceSubmitBtnState> {
  UserPreferenceSubmitBtnController(
    this._userPreferenceService,
    this._authUserService,
  ) : super(
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
      await Future.delayed(const Duration(seconds: 3));
      await _userPreferenceService.saveUserPreference(
        uid,
        UserPreference(prefences),
      );
      emit(UserPreferenceSubmitBtnSuccess());
    } catch (e) {
      emit(UserPreferenceSubmitBtnError());
    }
  }
}
