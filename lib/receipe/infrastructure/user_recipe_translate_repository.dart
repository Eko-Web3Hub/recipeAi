import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_recipe_translate.dart';
import 'package:recipe_ai/receipe/infrastructure/serialization/receipe_api_serialization.dart';
import 'package:recipe_ai/utils/constant.dart';

class FirestoreUserRecipeTranslateRepository
    implements IUserRecipeTranslateRepository {
  FirestoreUserRecipeTranslateRepository(this._firestore);

  static const String userReceipeTranslateCollection = "UserReceipeTranslate";

  @override
  Stream<Receipe?> watchTranslatedRecipe({
    required EntityId uid,
    required AppLanguage language,
    required EntityId recipeName,
  }) {
    return _firestore
        .collection(userReceipeTranslateCollection)
        .doc(uid.value)
        .collection(language.name)
        .doc(recipeName.value)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      final data = snapshot.data()!;
      return ReceipeApiSerialization.fromJson(data);
    });
  }

  final FirebaseFirestore _firestore;

  @override
  Future<void> removeTranslatedRecipe({
    required EntityId uid,
    required AppLanguage language,
    required EntityId recipeName,
  }) {
    return _firestore
        .collection(userReceipeTranslateCollection)
        .doc(uid.value)
        .collection(language.name)
        .doc(recipeName.value)
        .delete();
  }

  @override
  Future<void> saveTranslatedRecipe({
    required EntityId uid,
    required AppLanguage language,
    required EntityId recipeName,
    required Receipe receipe,
  }) {
    return _firestore
        .collection(userReceipeTranslateCollection)
        .doc(uid.value)
        .collection(language.name)
        .doc(recipeName.value)
        .set(ReceipeApiSerialization.toJson(receipe));
  }

  @override
  Future<void> saveTranslatedRecipes({
    required EntityId uid,
    required AppLanguage language,
    required List<Receipe> receipes,
  }) {
    final batch = _firestore.batch();
    final collectionRef = _firestore
        .collection(userReceipeTranslateCollection)
        .doc(uid.value)
        .collection(language.name);

    for (final receipe in receipes) {
      final docRef = collectionRef.doc(
        receipe.firestoreRecipeId!.value,
      );
      batch.set(docRef, ReceipeApiSerialization.toJson(receipe));
    }

    return batch.commit();
  }

  @override
  Future<Receipe?> getTranslatedRecipe({
    required EntityId uid,
    required AppLanguage language,
    required EntityId recipeName,
  }) {
    return _firestore
        .collection(userReceipeTranslateCollection)
        .doc(uid.value)
        .collection(language.name)
        .doc(recipeName.value)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        return ReceipeApiSerialization.fromJson(snapshot.data()!);
      }
      return null;
    });
  }
}
