import 'dart:io';

import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';

abstract class IUserReceipeRepositoryV2 {
  Future<UserReceipe?> getReceipesBasedOnUserPreferencesFromFirestore(
    EntityId uid,
  );
  Future<TranslatedRecipe> getReceipesBasedOnUserPreferencesFromApi(
      EntityId uid);

  Future<TranslatedRecipe?> genererateRecipesWithIngredientPicture(File file);

  Future<List<UserReceipeV2>> save(
    EntityId uid,
    List<UserReceipeV2> userReceipe,
  );

  Future<void> deleteUserReceipe(EntityId uid);

  Stream<List<Receipe>> watchAllSavedReceipes(EntityId uid);

  Stream<UserReceipe?> watchUserReceipe(EntityId uid);

  Future<void> saveOneReceipt(EntityId uid, EntityId receipeId);
  Future<bool> isOneReceiptSaved(EntityId uid, String receipeName);
  Stream<bool> isReceiptSaved(EntityId uid, EntityId receipeId);

  Future<void> translateUserReceipe(EntityId uid, String language);

  Future<void> removeSavedReceipe(EntityId uid, EntityId receipeId);
}
