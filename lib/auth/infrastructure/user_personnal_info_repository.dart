import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_ai/auth/domain/model/user_personnal_info.dart';
import 'package:recipe_ai/auth/domain/repositories/user_personnal_info_repository.dart';
import 'package:recipe_ai/auth/infrastructure/serialization/user_personnal_info_serialization.dart';
import 'package:recipe_ai/ddd/entity.dart';

class FirestoreUserPersonnalInfoRepository
    implements IUserPersonnalInfoRepository {
  static const _collection = 'UserPersonnalInfo';

  final FirebaseFirestore _firestore;

  FirestoreUserPersonnalInfoRepository(
    this._firestore,
  );

  @override
  Future<UserPersonnalInfo?> get(EntityId uid) async {
    final docRef = _firestore.collection(_collection).doc(uid.value);
    final docSnaphot = await docRef.get();
    if (!docSnaphot.exists) {
      return null;
    }
    final data = docSnaphot.data()!;

    return UserPersonnalInfoSerialization.fromMap(data);
  }

  @override
  Future<void> save(UserPersonnalInfo userPersonnalInfo) {
    return _firestore
        .collection(_collection)
        .doc(userPersonnalInfo.uid.value)
        .set(
          UserPersonnalInfoSerialization.toJson(userPersonnalInfo),
        );
  }

  @override
  Stream<UserPersonnalInfo?> watch(EntityId uid) {
    final docRef = _firestore.collection(_collection).doc(uid.value);
    return docRef.snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }
      final data = doc.data()!;
      return UserPersonnalInfoSerialization.fromMap(data);
    });
  }
}
