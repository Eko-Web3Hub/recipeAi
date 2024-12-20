import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/domain/model/user_personnal_info.dart';
import 'package:recipe_ai/auth/domain/repositories/user_personnal_info_repository.dart';
import 'package:recipe_ai/ddd/entity.dart';

abstract class IUserPersonnalInfoService {
  Stream<UserPersonnalInfo?> watch();
}

class UserPersonnalInfoService implements IUserPersonnalInfoService {
  final IUserPersonnalInfoRepository _userPersonnalInfoRepository;
  final IAuthUserService _authUserService;
  const UserPersonnalInfoService(
    this._userPersonnalInfoRepository,
    this._authUserService,
  );

  @override
  Stream<UserPersonnalInfo?> watch() {
    final uid = EntityId(_authUserService.currentUser!.uid);

    return _userPersonnalInfoRepository.watch(uid);
  }
}
