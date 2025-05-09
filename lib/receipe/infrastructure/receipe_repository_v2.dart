import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository_v2.dart';
import 'package:recipe_ai/utils/constant.dart';

class UserReceipeRepositoryV2 implements IUserReceipeRepositoryV2 {
  static const String baseUrl =
      "$baseApiUrl/v2/gen-receipe-with-user-preference";

  static const String receipesCollection = "receipes";

  static const String userReceipeV2Collection = "UserReceipeV2";

  static const String _isForHomeKey = 'isForHome';

  static const String _isAddedToFavoritesKey = 'isAddedToFavorites';

  static const String _createdDateKey = 'createdDate';

  // static const String _createdDateKey = 'createdDate';

  final FirebaseFirestore _firestore;

  const UserReceipeRepositoryV2(
    this._firestore,
    this._dio,
  );
  final Dio _dio;

  @override
  Future<TranslatedRecipe> getReceipesBasedOnUserPreferencesFromApi(
      EntityId uid) async {
    final apiRoute = "$baseUrl/${uid.value}";
    final response = await _dio.get(apiRoute);
    log(response.toString());
    final json = response.data as Map<String, dynamic>;

    return TranslatedRecipe.fromJson(json);
  }

  @override
  Future<List<UserReceipeV2>> getReceipesBasedOnUserPreferencesFromFirestore(
    EntityId uid,
  ) async {
    final snapshot = await _firestore
        .collection(userReceipeV2Collection)
        .doc(uid.value)
        .collection(receipesCollection)
        .where(_isForHomeKey, isEqualTo: true)
        .get();

    if (snapshot.docs.isEmpty) {
      return [];
    }
    final userReceipes =
        snapshot.docs.map((doc) => UserReceipeV2.fromJson(doc.data())).toList();

    return userReceipes;
  }

  @override
  Future<List<UserReceipeV2>> save(
    EntityId uid,
    List<UserReceipeV2> userReceipe,
  ) async {
    final recipesWithId = <UserReceipeV2>[];

    for (final receipe in userReceipe) {
      final docRef = _firestore
          .collection(userReceipeV2Collection)
          .doc(uid.value)
          .collection(receipesCollection)
          .doc();

      final docId = docRef.id;
      final receipeWithId = receipe.assignId(EntityId(docId));
      await docRef.set(receipeWithId.toJson());
      recipesWithId.add(receipeWithId);
    }

    return recipesWithId;
  }

  @override
  Stream<List<UserReceipeV2>> watchAllSavedReceipes(EntityId uid) {
    return _firestore
        .collection(userReceipeV2Collection)
        .doc(uid.value)
        .collection(receipesCollection)
        .where(_isAddedToFavoritesKey, isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return [];
      }
      final userReceipes = snapshot.docs
          .map((doc) => UserReceipeV2.fromJson(doc.data()))
          .toList();

      return userReceipes;
    });
  }

  @override
  Stream<bool> isReceiptSaved(EntityId uid, EntityId receipeId) {
    return _firestore
        .collection(userReceipeV2Collection)
        .doc(uid.value)
        .collection(receipesCollection)
        .doc(receipeId.value)
        .snapshots()
        .map((snapshot) =>
            snapshot.exists &&
            snapshot.data() != null &&
            snapshot.data()![_isAddedToFavoritesKey] == true);
  }

  @override
  Stream<List<UserReceipeV2>> watchUserReceipe(EntityId uid) {
    return _firestore
        .collection(userReceipeV2Collection)
        .doc(uid.value)
        .collection(receipesCollection)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return [];
      }
      final userReceipes = snapshot.docs
          .map((doc) => UserReceipeV2.fromJson(doc.data()))
          .toList();

      return userReceipes;
    });
  }

  @override
  Future<void> delete({
    required EntityId uid,
    required EntityId receipeId,
  }) {
    return _firestore
        .collection(userReceipeV2Collection)
        .doc(uid.value)
        .collection(receipesCollection)
        .doc(receipeId.value)
        .delete();
  }

  @override
  Future<UserRecipeMetadata?> getUserReceipeMetadata(
    EntityId uid,
  ) async {
    final snapshot = await _firestore
        .collection(userReceipeV2Collection)
        .doc(uid.value)
        .get();

    if (snapshot.exists) {
      final data = snapshot.data();
      if (data != null) {
        return UserRecipeMetadata.fromJson(data);
      }
    }
    return null;
  }

  @override
  Future<void> saveUserReceipeMetadata(
    EntityId uid,
    UserRecipeMetadata metadata,
  ) {
    return _firestore.collection(userReceipeV2Collection).doc(uid.value).set(
          metadata.toJson(),
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> translateUserReceipe(EntityId uid, String language) {
    final url = "$baseApiUrl/translate-recipes/${uid.value}/French";

    return _dio.post(url);
  }

  @override
  Future<TranslatedRecipe?> genererateRecipesWithIngredientPicture(
      File file) async {
    try {
      final apiRoute = "$baseApiUrl/gen-receipe-with-ingredient-picture";
      final fileToSend = await MultipartFile.fromFile(
        file.path,
        filename: file.path.split("/").last,
      );
      final formData = FormData.fromMap({
        "file": fileToSend,
      });
      final response = await _dio.post(apiRoute, data: formData);

      final json = response.data as Map<String, dynamic>;

      return TranslatedRecipe.fromJson(json);
    } catch (e) {
      log('An error occurred while generating recipes with ingredients picture: $e');
      return null;
    }
  }

  @override
  Future<void> saveUserReceipe(EntityId uid, UserReceipeV2 recipe) {
    return _firestore
        .collection(userReceipeV2Collection)
        .doc(uid.value)
        .collection(receipesCollection)
        .doc(recipe.id!.value)
        .set(recipe.toJson());
  }

  @override
  Future<List<UserReceipeV2>> getHomeUserReceipes(EntityId uid) async {
    final recipesDocs = await _firestore
        .collection(userReceipeV2Collection)
        .doc(uid.value)
        .collection(receipesCollection)
        .where(_isForHomeKey, isEqualTo: true)
        .get();

    return recipesDocs.docs
        .map<UserReceipeV2>(
            (userRecipe) => UserReceipeV2.fromJson(userRecipe.data()))
        .toList();
  }

  @override
  Future<List<UserReceipeV2>> getAllUserRecipe(EntityId uid) async {
    final docSnapshot = await _firestore
        .collection(userReceipeV2Collection)
        .doc(uid.value)
        .collection(receipesCollection)
        .orderBy(_createdDateKey, descending: true)
        .get();

    final docs = docSnapshot.docs;

    return docs
        .map<UserReceipeV2>((userRecipe) => UserReceipeV2.fromJson(
              userRecipe.data(),
            ))
        .toList();
  }

  @override
  Future<UserReceipeV2?> getRecipeByName(
    AppLanguage appLanguage,
    EntityId recipeName,
    EntityId uid,
  ) async {
    final filterKey =
        appLanguage == AppLanguage.fr ? 'receipeFr.name' : 'receipeEn.name';

    final docSnapshot = await _firestore
        .collection(userReceipeV2Collection)
        .doc(uid.value)
        .collection(receipesCollection)
        .where(
          filterKey,
          isEqualTo: recipeName.value.replaceAll('_', ' '),
        )
        .get();

    final docs = docSnapshot.docs;
    if (docs.isEmpty) {
      return null;
    }

    final userRecipe = docs.first;
    return UserReceipeV2.fromJson(userRecipe.data());
  }
}
