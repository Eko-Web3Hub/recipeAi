import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference.dart';

abstract class IUserPreferenceRepository {
  Future<UserPreference> retrieve(EntityId uid);
  Future<void> save(EntityId uid, UserPreference userPreference);
}
