import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/user_account/domain/models/user_account_meta_data.dart';
import 'package:recipe_ai/user_account/domain/repositories/user_account_meta_data_repository.dart';

abstract class IUserAccountMetaDataService {
  Future<UserAccountMetaData?> getAccountMetadata();

  Future<void> saveRecentLoginDate(
    DateTime now,
  );
}

class UserAccountMetaDataService implements IUserAccountMetaDataService {
  const UserAccountMetaDataService(
    this._userAccountMetaDataRepository,
    this._authUserService,
  );

  final IUserAccountMetaDataRepository _userAccountMetaDataRepository;

  @override
  Future<UserAccountMetaData?> getAccountMetadata() async {
    final uid = _authUserService.currentUser!.uid;

    return _userAccountMetaDataRepository.getUserAccount(uid);
  }

  final IAuthUserService _authUserService;

  @override
  Future<void> saveRecentLoginDate(DateTime now) async {
    final uid = _authUserService.currentUser!.uid;
    final currentUserAccountMetaData =
        await _userAccountMetaDataRepository.getUserAccount(uid);
    assert(
      currentUserAccountMetaData != null,
      'User account metadata should not be null when saving recent login date.',
    );
    final updatedUserAccountMetaData =
        currentUserAccountMetaData!.updateLastLogin(
      now,
    );

    return _userAccountMetaDataRepository.save(
      uid,
      updatedUserAccountMetaData,
    );
  }
}
