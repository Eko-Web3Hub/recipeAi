import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference_question.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/user_preference_quizz_repository.dart';

abstract class UserPreferenceQuizzState {}

class UserPreferenceQuizzLoading extends UserPreferenceQuizzState {}

class UserPreferenceQuizzLoaded extends UserPreferenceQuizzState {
  UserPreferenceQuizzLoaded(
    this.questions,
  );

  final List<UserPreferenceQuestion> questions;
}

class UserPreferenceQuizzError extends UserPreferenceQuizzState {}

class UserPreferenceQuizzController extends Cubit<UserPreferenceQuizzState> {
  UserPreferenceQuizzController(
    this._userPreferenceQuizzRepository,
  ) : super(UserPreferenceQuizzLoading()) {
    _load();
  }

  final IUserPreferenceQuizzRepository _userPreferenceQuizzRepository;

  Future<void> _load() async {
    final questions = await _userPreferenceQuizzRepository.retrieve();
    emit(UserPreferenceQuizzLoaded(questions));
  }
}
