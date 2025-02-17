import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/user_account/domain/models/user_account_meta_data.dart';

abstract class IUserAccountMetaDataRepository {
  Future<UserAccountMetaData?> getUserAccount(EntityId uid);
  Future<void> save(EntityId uid, UserAccountMetaData userAccount);
}
