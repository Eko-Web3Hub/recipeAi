import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/user_account/domain/models/user_account_meta_data.dart';
import 'package:recipe_ai/user_account/domain/repositories/user_account_meta_data_repository.dart';

class FirestoreUserAccountMetaRepository
    implements IUserAccountMetaDataRepository {
  final FirebaseFirestore _firestore;

  FirestoreUserAccountMetaRepository(this._firestore);

  static const String _collectionName = 'UserAccountMetaData';

  @override
  Future<UserAccountMetaData?> getUserAccount(EntityId uid) {
    return _firestore.collection(_collectionName).doc(uid.value).get().then(
      (snapshot) {
        if (snapshot.exists) {
          return UserAccountMetaData.fromJson(snapshot.data()!);
        }
        return null;
      },
    );
  }

  @override
  Future<void> save(EntityId uid, UserAccountMetaData userAccount) {
    return _firestore.collection(_collectionName).doc(uid.value).set(
          userAccount.toJson(),
        );
  }
}
