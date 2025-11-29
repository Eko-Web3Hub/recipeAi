import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository.dart';
import 'package:recipe_ai/receipe/infrastructure/serialization/receipe_serialization.dart';
import 'package:recipe_ai/receipe/infrastructure/user_receipe_serialization.dart';
import 'package:recipe_ai/utils/constant.dart';

class UserReceipeRepository implements IUserReceipeRepository {
  static const String baseUrl =
      "$baseApiUrl/v2/gen-receipe-with-user-preference";
  static const String kitchenInventoryCollection = "KitchenInventory";
  static const String receipesCollection = "receipes";

  static const String userReceipeCollection = "UserReceipe";

  final FirebaseFirestore _firestore;

  const UserReceipeRepository(this._firestore);

  @override
  Future<void> save(EntityId uid, UserReceipe userReceipe) {
    return _firestore.collection(userReceipeCollection).doc(uid.value).set(
          UserReceipeSerialization.toJson(userReceipe),
          SetOptions(merge: true),
        );
  }

  @override
  Stream<List<Receipe>> watchAllSavedReceipes(EntityId uid) {
    return _firestore
        .collection(kitchenInventoryCollection)
        .doc(uid.value)
        .collection(receipesCollection)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map<Receipe>(
            (doc) => ReceipeSerialization.fromJson(doc.data()),
          )
          .toList();
    });
  }

  @override
  Future<bool> isOneReceiptSaved(EntityId uid, String receipeName) {
    return _firestore
        .collection(kitchenInventoryCollection)
        .doc(uid.value)
        .collection(receipesCollection)
        .doc(receipeName)
        .get()
        .then((value) => value.exists);
  }

  @override
  Stream<bool> isReceiptSaved(EntityId uid, String receipeName) {
    return _firestore
        .collection(kitchenInventoryCollection)
        .doc(uid.value)
        .collection(receipesCollection)
        .doc(receipeName)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  @override
  Future<void> saveOneReceipt(EntityId uid, Receipe receipe) {
    return _firestore
        .collection(kitchenInventoryCollection)
        .doc(uid.value)
        .collection(receipesCollection)
        .doc(receipe.name.toLowerCase().replaceAll(' ', ''))
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

  @override
  Stream<UserReceipe?> watchUserReceipe(EntityId uid) {
    return _firestore
        .collection(userReceipeCollection)
        .doc(uid.value)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      final data = snapshot.data()!;
      final userReceipe = UserReceipeSerialization.fromJson(data);

      return userReceipe;
    });
  }

  @override
  Future<void> deleteUserReceipe(EntityId uid) {
    return _firestore.collection(userReceipeCollection).doc(uid.value).delete();
  }
}
