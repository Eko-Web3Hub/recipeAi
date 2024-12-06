import 'package:recipe_ai/auth/domain/model/user_personnal_info.dart';
import 'package:recipe_ai/ddd/entity.dart';

abstract class IUserPersonnalInfoRepository {
  Future<UserPersonnalInfo?> get(EntityId uid);
  Future<void> save(UserPersonnalInfo userPersonnalInfo);
}
