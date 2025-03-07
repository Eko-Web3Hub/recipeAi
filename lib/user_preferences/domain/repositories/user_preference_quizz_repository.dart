import 'package:recipe_ai/user_preferences/domain/model/user_preference_question.dart';
import 'package:recipe_ai/utils/constant.dart';

abstract class IUserPreferenceQuizzRepository {
  Future<List<UserPreferenceQuestion>> retrieve(AppLanguage language);
}
