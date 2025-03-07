import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference_question.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/user_preference_quizz_repository.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/user_preference_repository.dart';
import 'package:recipe_ai/utils/constant.dart';

abstract class UserPreferenceUpdateState extends Equatable {}

class UserPreferenceUpdateLoading extends UserPreferenceUpdateState {
  @override
  List<Object?> get props => [];
}

class UserPreferenceUpdateLoaded extends UserPreferenceUpdateState {
  UserPreferenceUpdateLoaded(
    this.userPreferenceQuestion,
  );

  final List<UserPreferenceQuestion> userPreferenceQuestion;

  @override
  List<Object?> get props => [userPreferenceQuestion];
}

class UserPreferenceUpdateController extends Cubit<UserPreferenceUpdateState> {
  UserPreferenceUpdateController(
    this._authUserService,
    this._userPreferenceRepository,
    this._userPreferenceQuizzRepository, {
    required this.currentUserLanguage,
  }) : super(
          UserPreferenceUpdateLoading(),
        ) {
    _load();
  }

  Future<void> _load() async {
    final uid = _authUserService.currentUser!.uid;
    final newQuizz = <UserPreferenceQuestion>[];
    final userPreference = await _userPreferenceRepository.retrieve(uid);
    final userPreferenceQuizz = await _userPreferenceQuizzRepository.retrieve(
      currentUserLanguage,
    );

    for (final question in userPreferenceQuizz) {
      newQuizz.add(question.initWithUserPreference(userPreference));
    }
    emit(UserPreferenceUpdateLoaded(newQuizz));
  }

  final IAuthUserService _authUserService;
  final IUserPreferenceRepository _userPreferenceRepository;
  final IUserPreferenceQuizzRepository _userPreferenceQuizzRepository;
  final AppLanguage currentUserLanguage;
}
