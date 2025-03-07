import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference_question.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/user_preference_quizz_repository.dart';
import 'package:recipe_ai/utils/constant.dart';

abstract class UserPreferenceQuizzState extends Equatable {}

class UserPreferenceQuizzLoading extends UserPreferenceQuizzState {
  @override
  List<Object?> get props => [];
}

class UserPreferenceQuizzLoaded extends UserPreferenceQuizzState {
  UserPreferenceQuizzLoaded(
    this.questions,
  );

  final List<UserPreferenceQuestion> questions;

  @override
  List<Object?> get props => [questions];
}

class UserPreferenceQuizzError extends UserPreferenceQuizzState {
  @override
  List<Object?> get props => [];
}

class UserPreferenceQuizzController extends Cubit<UserPreferenceQuizzState> {
  UserPreferenceQuizzController(
    this._userPreferenceQuizzRepository, {
    required this.currentUserLanguage,
  }) : super(UserPreferenceQuizzLoading()) {
    _load();
  }

  final IUserPreferenceQuizzRepository _userPreferenceQuizzRepository;

  Future<void> _load() async {
    try {
      final questions = await _userPreferenceQuizzRepository.retrieve(
        currentUserLanguage,
      );
      emit(UserPreferenceQuizzLoaded(questions));
    } catch (e) {
      log(e.toString());
      emit(UserPreferenceQuizzError());
    }
  }

  final AppLanguage currentUserLanguage;
}
