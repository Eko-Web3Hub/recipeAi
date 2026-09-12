import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference.dart';
import 'package:recipe_ai/user_preferences/infrastructure/serialization/user_preference_serialization.dart';

import '../domain/repositories/user_preference_repository.dart';

class FirestoreUserPreferenceRepository implements IUserPreferenceRepository {
  const FirestoreUserPreferenceRepository(this._firestore);

  static const String _collection = 'UserPreference';

  final FirebaseFirestore _firestore;

  @override
  Future<UserPreference> retrieve(EntityId uid) async {
    // The cache is keyed by uid: signing in with another account in the same
    // session must not hand back the previous user's preferences.
    if (_userPreference != null && _cachedUid == uid.value) {
      return _userPreference!;
    }

    try {
      final snapshot = await _firestore
          .collection(_collection)
          .doc(uid.value)
          .get();
      if (!snapshot.exists) {
        _userPreference = null;
        _cachedUid = null;
        return const UserPreference({});
      }

      final data = snapshot.data();
      final serilizedData = UserPreferenceSerialization.fromJson(data!);
      _userPreference = serilizedData;
      _cachedUid = uid.value;

      return serilizedData;
    } catch (e) {
      log(e.toString());
      return Future.value(const UserPreference({}));
    }
  }

  static UserPreference? _userPreference;
  static String? _cachedUid;

  @override
  Future<void> save(EntityId uid, UserPreference userPreference) async {
    _userPreference = userPreference;
    _cachedUid = uid.value;

    try {
      await _firestore
          .collection(_collection)
          .doc(uid.value)
          .set(
            UserPreferenceSerialization.toJson(userPreference),
            SetOptions(merge: true),
          );
    } catch (e) {
      log(e.toString());
    }
  }
}
