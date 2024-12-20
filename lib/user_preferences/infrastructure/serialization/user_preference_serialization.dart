import 'package:recipe_ai/user_preferences/domain/model/user_preference.dart';

abstract class UserPreferenceSerialization {
  static UserPreference fromJson(Map<String, dynamic> json) {
    return UserPreference(json);
  }

  static Map<String, dynamic> toJson(UserPreference userPreference) {
    return userPreference.preferences;
  }
}
