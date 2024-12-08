import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference.dart';
import 'package:recipe_ai/user_preferences/infrastructure/serialization/user_preference_serialization.dart';

import '../domain/repositories/user_preference_repository.dart';

class FirestoreUserPreferenceRepository implements IUserPreferenceRepository {
  const FirestoreUserPreferenceRepository(
    this._firestore,
  );

  static const String _collection = 'UserPreference';

  final FirebaseFirestore _firestore;

  @override
  Future<UserPreference> retrieve(EntityId uid) async {
    try {
      final snapshot =
          await _firestore.collection(_collection).doc(uid.value).get();
      if (!snapshot.exists) {
        return const UserPreference({});
      }

      final data = snapshot.data();
      return UserPreferenceSerialization.fromJson(data!);
    } catch (e) {
      log(e.toString());
      return Future.value(const UserPreference({}));
    }
  }

  @override
  Future<void> save(EntityId uid, UserPreference userPreference) async {
    try {
      await _firestore.collection(_collection).doc(uid.value).set(
            UserPreferenceSerialization.toJson(userPreference),
            SetOptions(
              merge: true,
            ),
          );
    } catch (e) {
      log(e.toString());
    }
  }
}
