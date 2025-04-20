import 'dart:io';

import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';

abstract class IUserReceipeRepositoryV2 {
  Future<List<UserReceipeV2>> getReceipesBasedOnUserPreferencesFromFirestore(
    EntityId uid,
  );

  Future<TranslatedRecipe> getReceipesBasedOnUserPreferencesFromApi(
      EntityId uid);

  Future<TranslatedRecipe?> genererateRecipesWithIngredientPicture(File file);

  Future<List<UserReceipeV2>> save(
    EntityId uid,
    List<UserReceipeV2> userReceipe,
  );

  Future<void> saveUserReceipe(EntityId uid, UserReceipeV2 recipe);

  Future<void> delete({
    required EntityId uid,
    required EntityId receipeId,
  });

  Stream<List<UserReceipeV2>> watchAllSavedReceipes(EntityId uid);

  Future<List<UserReceipeV2>> getHomeUserReceipes(EntityId uid);

  Stream<List<UserReceipeV2>> watchUserReceipe(EntityId uid);

  Future<List<UserReceipeV2>> getAllUserRecipe(EntityId uid);

  Stream<bool> isReceiptSaved(EntityId uid, EntityId receipeId);

  Future<UserRecipeMetadata?> getUserReceipeMetadata(
    EntityId uid,
  );

  Future<void> saveUserReceipeMetadata(
      EntityId uid, UserRecipeMetadata metadata);

  Future<void> translateUserReceipe(EntityId uid, String language);
}
