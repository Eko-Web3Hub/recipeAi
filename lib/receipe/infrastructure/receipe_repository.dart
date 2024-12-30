import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/saved_receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository.dart';
import 'package:recipe_ai/receipe/infrastructure/serialization/receipe_api_serialization.dart';
import 'package:recipe_ai/receipe/infrastructure/serialization/receipe_serialization.dart';
import 'package:recipe_ai/receipe/infrastructure/serialization/saved_receipe_serialization.dart';
import 'package:recipe_ai/receipe/infrastructure/user_receipe_serialization.dart';
import 'package:recipe_ai/utils/constant.dart';

class UserReceipeRepository implements IUserReceipeRepository {
  static const String baseUrl = "$baseApiUrl/gen-receipe-with-user-preference";
  static const String kitchenInventoryCollection = "KitchenInventory";
  static const String receipesCollection = "receipes";

  static const String userReceipeCollection = "UserReceipe";

  final FirebaseFirestore _firestore;

  const UserReceipeRepository(this._firestore, this._dio);
  final Dio _dio;

  @override
  Future<List<Receipe>> getReceipesBasedOnUserPreferencesFromApi(
      EntityId uid) async {
    final apiRoute = "$baseUrl/${uid.value}";
    final response = await _dio.get(apiRoute);
    log(response.toString());
    final json = response.data as Map<String, dynamic>;
    final results = json["receipes"] as List;
    return results
        .map<Receipe>(
          (receipe) => ReceipeApiSerialization.fromJson(receipe),
        )
        .toList();
  }

  @override
  Future<UserReceipe?> getReceipesBasedOnUserPreferencesFromFirestore(
    EntityId uid,
  ) async {
    final snapshot =
        await _firestore.collection(userReceipeCollection).doc(uid.value).get();

    if (!snapshot.exists) {
      return null;
    }
    final data = snapshot.data()!;

    return UserReceipeSerialization.fromJson(data);
  }

  @override
  Future<void> save(EntityId uid, UserReceipe userReceipe) {
    return _firestore.collection(userReceipeCollection).doc(uid.value).set(
          UserReceipeSerialization.toJson(userReceipe),
          SetOptions(merge: true),
        );
  }

  @override
  Stream<List<SavedReceipe>> watchAllSavedReceipes(EntityId uid) {
    return _firestore
        .collection(kitchenInventoryCollection)
        .doc(uid.value)
        .collection(receipesCollection)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map<SavedReceipe>(
        (doc) {
          return SavedReceipeSerialization.fromQueryDocumentSnapshot(doc);
        },
      ).toList();
    });
  }

  @override
  Future<bool> isOneReceiptSaved(EntityId uid, int index) {
    return _firestore
        .collection(kitchenInventoryCollection)
        .doc(uid.value)
        .collection(receipesCollection)
        .doc("${uid.value}$index")
        .get()
        .then((value) => value.exists);
  }

  @override
  Future<void> saveOneReceipt(EntityId uid, int index, Receipe receipe) {
    return _firestore
        .collection(kitchenInventoryCollection)
        .doc(uid.value)
        .collection(receipesCollection)
        .doc("${uid.value}$index")
        .set(ReceipeSerialization.toJson(receipe), SetOptions(merge: true));
  }

  @override
  Future<void> removeSavedReceipe(EntityId uid, String documentId) {
    return _firestore
        .collection(kitchenInventoryCollection)
        .doc(uid.value)
        .collection(receipesCollection)
        .doc(documentId)
        .delete();
  }
}
