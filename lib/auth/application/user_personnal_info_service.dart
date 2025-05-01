import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/domain/model/user_personnal_info.dart';
import 'package:recipe_ai/auth/domain/repositories/user_personnal_info_repository.dart';

abstract class IUserPersonnalInfoService {
  Future<void> changeUsername(String username);
  Future<UserPersonnalInfo?> get();
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
  Future<UserPersonnalInfo?> get() async {
    final uid = _authUserService.currentUser!.uid;

    return _userPersonnalInfoRepository.get(uid);
  }

  @override
  Stream<UserPersonnalInfo?> watch() {
    final uid = _authUserService.currentUser!.uid;

    return _userPersonnalInfoRepository.watch(uid);
  }

  @override
  Future<void> changeUsername(String username) async {
    final currentUserPersonalInfo = await get();
    final newUserPersonalInfo =
        currentUserPersonalInfo!.changeUsername(username);

    await _userPersonnalInfoRepository.save(newUserPersonalInfo);
  }
}
