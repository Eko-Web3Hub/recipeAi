import 'package:recipe_ai/auth/application/auth_service.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/domain/model/user_personnal_info.dart';
import 'package:recipe_ai/auth/domain/repositories/user_personnal_info_repository.dart';
import 'package:recipe_ai/utils/app_text.dart';

class RegisterUsecase {
  final IAuthService _authService;
  final IAuthUserService _authUserService;
  final IUserPersonnalInfoRepository _userPersonnalInfoRepository;

  RegisterUsecase(
    this._authService,
    this._authUserService,
    this._userPersonnalInfoRepository,
  );

  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    await _authService.register(
      email: email,
      password: password,
    );
    final user = _authUserService.currentUser;
    if (user == null) {
      throw AuthException(
        AppText.registerFailed,
      );
    }
    await _userPersonnalInfoRepository.save(
      UserPersonnalInfo(
        uid: user.uid,
        email: email,
        name: name,
      ),
    );

    return true;
  }
}
