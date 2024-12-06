import 'package:recipe_ai/user_preferences/domain/model/user_preference_question.dart';

abstract class IUserPreferenceQuizzRepository {
  Future<List<UserPreferenceQuestion>> retrieve();
}
