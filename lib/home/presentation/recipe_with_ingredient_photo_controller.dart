import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_recipe_translate.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/functions.dart';

abstract class RecipeWithIngredientPhotoState {}

class RecipeWithIngredientPhotoController extends Cubit<bool> {
  RecipeWithIngredientPhotoController(
    this._userReceipeRepository,
    this._authUserService,
    this._userRecipeTranslateRepository,
    this.receipe,
    this.receipeFr,
  ) : super(false) {
    _load();
  }

  void _load() {
    final uid = _authUserService.currentUser!.uid;
    final recipeId = receipe.name.toLowerCase().replaceAll(' ', '');
    log('Recipe with ingredient photo ID: $recipeId');

    _userReceipeRepository.isReceiptSaved(uid, recipeId).listen((isSaved) {
      emit(isSaved);
    });
  }

  void toggleFavorite() async {
    final uid = _authUserService.currentUser!.uid;
    final recipeId = receipe.name.toLowerCase().replaceAll(' ', '');
    final recipeTranslateName = convertRecipeNameToFirestoreId(receipe.name);
    log('Toggling favorite for recipe ID: $recipeId');

    if (state) {
      await _userReceipeRepository.removeSavedReceipe(uid, recipeId);
      await _userRecipeTranslateRepository.removeTranslatedRecipe(
        uid: uid,
        language: AppLanguage.fr,
        recipeName: EntityId(recipeTranslateName),
      );
    } else {
      await _userReceipeRepository.saveOneReceipt(uid, receipe);
      await _userRecipeTranslateRepository.saveTranslatedRecipe(
        uid: uid,
        language: AppLanguage.fr,
        recipeName: EntityId(recipeTranslateName),
        receipe: receipeFr,
      );
    }
  }

  final IUserReceipeRepository _userReceipeRepository;
  final IAuthUserService _authUserService;
  final Receipe receipe;
  final Receipe receipeFr;
  final IUserRecipeTranslateRepository _userRecipeTranslateRepository;
}
