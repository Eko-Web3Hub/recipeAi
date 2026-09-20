import 'dart:io';

import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_finished_recipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';

abstract class IUserReceipeRepositoryV2 {
  /// Looks up a recipe by id in the global `recipes` collection (the shared
  /// catalog a recipe-details deep link points to), independent of any user.
  Future<UserRecipeV2?> getRecipeById(EntityId recipeId);

  Future<List<UserRecipeV2>> getReceipesBasedOnUserPreferencesFromFirestore(
    EntityId uid,
  );

  Future<List<UserRecipeV2>> suggestedRecipes(EntityId uid, String token);

  Future<List<UserRecipeV2>> genererateRecipesWithIngredientPicture(
    EntityId uid,
    String token,
    File file,
  );

  Future<RawRecipeFindWithImage> findRecipeWithImage(String recipePathImage);

  Future<List<UserRecipeV2>> save(EntityId uid, List<UserRecipeV2> userReceipe);

  Future<void> saveUserReceipe(EntityId uid, UserRecipeV2 recipe);

  Future<void> delete({required EntityId uid, required EntityId receipeId});

  Future<List<UserRecipeV2>> getHomeUserReceipes(EntityId uid);

  Stream<List<UserRecipeV2>> watchUserReceipe(EntityId uid);

  Future<List<UserRecipeV2>> getAllUserRecipe(EntityId uid);

  /// Number of recipes the user generated (from ingredients or a photo).
  Future<int> countGeneratedRecipes(EntityId uid);

  Stream<bool> isReceiptSaved(EntityId uid, EntityId receipeId);

  Future<UserRecipeMetadata?> getUserRecipeMetadata(EntityId uid);

  Future<void> saveUserReceipeMetadata(
    EntityId uid,
    UserRecipeMetadata metadata,
  );

  Future<void> markRecipeAsFinished({
    required EntityId uid,
    required UserFinishedRecipe recipe,
  });

  Stream<RecipeCookedSummary?> recipeCookedSummary({
    required EntityId uid,
    required EntityId recipeId,
  });

  Future<void> addToFavorite({
    required EntityId uid,
    required EntityId recipeId,
    required UserRecipeV2 recipe,
  });

  Future<void> removeFromFavorite({
    required EntityId uid,
    required EntityId recipeId,
  });

  Stream<List<UserRecipeV2>> retrieveFavoriteRecipes(EntityId uid);
}
