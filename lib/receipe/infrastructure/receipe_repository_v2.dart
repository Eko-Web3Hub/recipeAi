import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_finished_recipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository_v2.dart';
import 'package:recipe_ai/utils/constant.dart';

class UserReceipeRepositoryV2 implements IUserReceipeRepositoryV2 {
  static const String baseUrl =
      "$baseApiUrl/v2/gen-receipe-with-user-preference";

  static const String recipesSuggestionEngineBaseUrl =
      'https://recipes-suggestions-v7duguwfla-ew.a.run.app';

  static const String receipesCollection = "receipes";

  static const String _recipeCollection = 'recipes';

  static const String _favoriteRecipeCollection = 'FavoriteRecipes';

  static const String userReceipeV2Collection = "UserReceipeV2";

  static const String _isForHomeKey = 'isForHome';

  static const String _createdDateKey = 'createdDate';

  static const String _userFinishedReceipesCollection = 'UserFinishedReceipes';

  /// The global, user-independent recipe catalog a recipe-details deep link
  /// points to (populated outside of this app).
  static const String _globalRecipesCollection = 'recipes';

  // static const String _createdDateKey = 'createdDate';

  final FirebaseFirestore _firestore;

  const UserReceipeRepositoryV2(this._firestore, this._dio);
  final Dio _dio;

  @override
  Future<List<UserRecipeV2>> suggestedRecipes(
    EntityId uid,
    String token,
  ) async {
    try {
      final apiRoute =
          "$recipesSuggestionEngineBaseUrl/suggestions/${uid.value}";
      final response = await _dio.get(
        apiRoute,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            "Accept": 'application/json',
            "Authorization": "Bearer $token",
          },
        ),
      );
      log(response.toString());
      final recipes = response.data['recipes'] as List<dynamic>;

      return recipes
          .map(
            (recipe) => UserRecipeV2.fromJson(recipe as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      log('An error occurred while fetching suggested recipes: $e');

      return [];
    }
  }

  @override
  Future<List<UserRecipeV2>> getReceipesBasedOnUserPreferencesFromFirestore(
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
    final userReceipes = snapshot.docs
        .map((doc) => UserRecipeV2.fromJson(doc.data()))
        .toList();

    return userReceipes;
  }

  @override
  Future<List<UserRecipeV2>> save(
    EntityId uid,
    List<UserRecipeV2> userReceipe,
  ) async {
    final recipesWithId = <UserRecipeV2>[];

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
  Stream<bool> isReceiptSaved(EntityId uid, EntityId receipeId) {
    return _firestore
        .collection(_userFinishedReceipesCollection)
        .doc(uid.value)
        .collection(_favoriteRecipeCollection)
        .doc(receipeId.value)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  @override
  Stream<List<UserRecipeV2>> watchUserReceipe(EntityId uid) {
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
              .map((doc) => UserRecipeV2.fromJson(doc.data()))
              .toList();

          return userReceipes;
        });
  }

  @override
  Future<void> delete({required EntityId uid, required EntityId receipeId}) {
    return _firestore
        .collection(userReceipeV2Collection)
        .doc(uid.value)
        .collection(receipesCollection)
        .doc(receipeId.value)
        .delete();
  }

  @override
  Future<UserRecipeMetadata?> getUserRecipeMetadata(EntityId uid) async {
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
    return _firestore
        .collection(userReceipeV2Collection)
        .doc(uid.value)
        .set(metadata.toJson(), SetOptions(merge: true));
  }

  @override
  Future<List<UserRecipeV2>> genererateRecipesWithIngredientPicture(
    EntityId uid,
    String token,
    File file,
  ) async {
    try {
      final apiRoute =
          "$recipesSuggestionEngineBaseUrl/suggestions/${uid.value}/from-photo";
      final fileToSend = await MultipartFile.fromFile(
        file.path,
        filename: file.path.split("/").last,
      );
      final formData = FormData.fromMap({"photo": fileToSend});
      final response = await _dio.post(
        apiRoute,
        data: formData,
        options: Options(
          receiveTimeout: timeOutDuration,
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      return (response.data['recipes'] as List)
          .map<UserRecipeV2>((recipe) => UserRecipeV2.fromJson(recipe))
          .toList();
    } on DioException catch (e, stackTrace) {
      final detail = e.response != null
          ? 'status=${e.response?.statusCode} body=${e.response?.data}'
          : e.message;
      log(
        'An error occurred while generating recipes with ingredients picture: $detail',
      );
      await FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'genererateRecipesWithIngredientPicture failed: $detail',
      );
      rethrow;
    } catch (e, stackTrace) {
      log(
        'An error occurred while generating recipes with ingredients picture: $e',
      );
      await FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'genererateRecipesWithIngredientPicture failed',
      );
      rethrow;
    }
  }

  @override
  Future<void> saveUserReceipe(EntityId uid, UserRecipeV2 recipe) {
    return _firestore
        .collection(userReceipeV2Collection)
        .doc(uid.value)
        .collection(receipesCollection)
        .doc(recipe.id!.value)
        .set(recipe.toJson());
  }

  @override
  Future<List<UserRecipeV2>> getHomeUserReceipes(EntityId uid) async {
    final recipesDocs = await _firestore
        .collection(userReceipeV2Collection)
        .doc(uid.value)
        .collection(receipesCollection)
        .where(_isForHomeKey, isEqualTo: true)
        .get();

    return recipesDocs.docs
        .map<UserRecipeV2>(
          (userRecipe) => UserRecipeV2.fromJson(userRecipe.data()),
        )
        .toList();
  }

  @override
  Future<int> countGeneratedRecipes(EntityId uid) async {
    final recipes = _firestore
        .collection(userReceipeV2Collection)
        .doc(uid.value)
        .collection(receipesCollection);

    // Older home suggestions were stored here too, flagged `isForHome`: they
    // were never generated by the user.
    final (all, forHome) = await (
      recipes.count().get(),
      recipes.where(_isForHomeKey, isEqualTo: true).count().get(),
    ).wait;

    return (all.count ?? 0) - (forHome.count ?? 0);
  }

  @override
  Future<List<UserRecipeV2>> getAllUserRecipe(EntityId uid) async {
    final docSnapshot = await _firestore
        .collection(userReceipeV2Collection)
        .doc(uid.value)
        .collection(receipesCollection)
        .orderBy(_createdDateKey, descending: true)
        .get();

    final docs = docSnapshot.docs;

    return docs
        .map<UserRecipeV2>(
          (userRecipe) => UserRecipeV2.fromJson(userRecipe.data()),
        )
        .toList();
  }

  @override
  Future<UserRecipeV2?> getRecipeById(EntityId recipeId) async {
    final docSnapshot = await _firestore
        .collection(_globalRecipesCollection)
        .doc(recipeId.value)
        .get();

    final data = docSnapshot.data();
    if (!docSnapshot.exists || data == null) {
      return null;
    }

    // The global `recipes` catalog doesn't store its own document id as a
    // field, so it's assigned explicitly from the doc reference we already
    // queried by.
    return UserRecipeV2.fromJson(data).assignId(recipeId);
  }

  @override
  Future<RawRecipeFindWithImage> findRecipeWithImage(
    String recipePathImage,
  ) async {
    final apiRoute = "$baseApiUrl/find-recipe-with-picture";
    final file = File(recipePathImage);

    final fileToSend = await MultipartFile.fromFile(
      file.path,
      filename: file.path.split("/").last,
    );
    final formData = FormData.fromMap({"file": fileToSend});
    final response = await _dio.post(
      apiRoute,
      data: formData,
      options: timeOutOptions,
    );

    final json = response.data as Map<String, dynamic>;

    return RawRecipeFindWithImage.fromJson(json);
  }

  @override
  Future<void> markRecipeAsFinished({
    required EntityId uid,
    required UserFinishedRecipe recipe,
  }) async => _firestore
      .collection(_userFinishedReceipesCollection)
      .doc(uid.value)
      .collection(_recipeCollection)
      .add(recipe.toJson());

  @override
  Stream<RecipeCookedSummary?> recipeCookedSummary({
    required EntityId uid,
    required EntityId recipeId,
  }) {
    return _firestore
        .collection(_userFinishedReceipesCollection)
        .doc(uid.value)
        .collection(_recipeCollection)
        .where('recipeId', isEqualTo: recipeId.value)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;

          final finishedDates = snapshot.docs
              .map((doc) => UserFinishedRecipe.fromJson(doc.data()).finishedAt)
              .whereType<DateTime>()
              .toList();

          return RecipeCookedSummary(
            count: snapshot.size,
            lastCookedAt: finishedDates.isEmpty
                ? null
                : finishedDates.reduce((a, b) => a.isAfter(b) ? a : b),
          );
        });
  }

  @override
  Future<void> addToFavorite({
    required EntityId uid,
    required EntityId recipeId,
    required UserRecipeV2 recipe,
  }) => _firestore
      .collection(_userFinishedReceipesCollection)
      .doc(uid.value)
      .collection(_favoriteRecipeCollection)
      .doc(recipeId.value)
      .set(recipe.toJson());

  @override
  Future<void> removeFromFavorite({
    required EntityId uid,
    required EntityId recipeId,
  }) => _firestore
      .collection(_userFinishedReceipesCollection)
      .doc(uid.value)
      .collection(_favoriteRecipeCollection)
      .doc(recipeId.value)
      .delete();

  @override
  Stream<List<UserRecipeV2>> retrieveFavoriteRecipes(EntityId uid) {
    return _firestore
        .collection(_userFinishedReceipesCollection)
        .doc(uid.value)
        .collection(_favoriteRecipeCollection)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => UserRecipeV2.fromJson(
                  doc.data(),
                  customId: EntityId(doc.id),
                ),
              )
              .toList(),
        );
  }
}
