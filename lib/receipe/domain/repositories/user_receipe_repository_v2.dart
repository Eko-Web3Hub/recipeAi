import 'dart:io';

import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/utils/constant.dart';

abstract class IUserReceipeRepositoryV2 {
  Future<UserRecipeV2?> getRecipeByName(
    AppLanguage appLanguage,
    EntityId recipeName,
    EntityId uid,
  );

  Future<List<UserRecipeV2>> getReceipesBasedOnUserPreferencesFromFirestore(
    EntityId uid,
  );

  Future<List<UserRecipeV2>> suggestedRecipes(EntityId uid, String token);

  Future<TranslatedRecipe?> genererateRecipesWithIngredientPicture(File file);

  Future<RawRecipeFindWithImage> findRecipeWithImage(String recipePathImage);

  Future<List<UserRecipeV2>> save(EntityId uid, List<UserRecipeV2> userReceipe);

  Future<void> saveUserReceipe(EntityId uid, UserRecipeV2 recipe);

  Future<void> delete({required EntityId uid, required EntityId receipeId});

  Stream<List<UserRecipeV2>> watchAllSavedReceipes(EntityId uid);

  Future<List<UserRecipeV2>> getHomeUserReceipes(EntityId uid);

  Stream<List<UserRecipeV2>> watchUserReceipe(EntityId uid);

  Future<List<UserRecipeV2>> getAllUserRecipe(EntityId uid);

  Stream<bool> isReceiptSaved(EntityId uid, EntityId receipeId);

  Future<UserRecipeMetadata?> getUserRecipeMetadata(EntityId uid);

  Future<void> saveUserReceipeMetadata(
    EntityId uid,
    UserRecipeMetadata metadata,
  );
}
