import 'package:recipe_ai/auth/domain/model/user_personnal_info.dart';

abstract class IUserPersonnalInfoRepository {
  Future<UserPersonnalInfo> get();
  Future<void> save(UserPersonnalInfo userPersonnalInfo);
}

class UserPersonnalInfoRepository implements IUserPersonnalInfoRepository {
  @override
  Future<UserPersonnalInfo> get() {
    throw UnimplementedError();
  }

  @override
  Future<void> save(UserPersonnalInfo userPersonnalInfo) {
    throw UnimplementedError();
  }
}
