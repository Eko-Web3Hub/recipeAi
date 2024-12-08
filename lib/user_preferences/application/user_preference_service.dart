import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/user_preference_repository.dart';

class UserPreferenceService {
  final IUserPreferenceRepository _userPreferenceRepository;

  const UserPreferenceService(
    this._userPreferenceRepository,
  );

  Future<void> saveUserPreference(
    EntityId uid,
    UserPreference userPreference,
  ) {
    return _userPreferenceRepository.save(uid, userPreference);
  }
}
