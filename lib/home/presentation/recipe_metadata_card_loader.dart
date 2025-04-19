import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/application/user_recipe_translate_service.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/user_account/domain/repositories/user_account_meta_data_repository.dart';
import 'package:recipe_ai/utils/functions.dart';
import 'package:recipe_ai/utils/safe_emit.dart';

class RecipeMetadataCardLoader extends Cubit<Receipe> {
  RecipeMetadataCardLoader(
    this.recipe,
    this._userRecipeTranslateService,
    this._userAccountMetaDataRepository,
    this._authUserService,
  ) : super(recipe) {
    _load();
  }

  void _load() {
    final recipeId = recipe.firestoreRecipeId?.value ??
        convertRecipeNameToFirestoreId(recipe.name);
    _subscription = _userAccountMetaDataRepository
        .watchUserAccount(_authUserService.currentUser!.uid)
        .listen((userAccount) async {
      if (userAccount != null) {
        final recipeTranslated =
            await _userRecipeTranslateService.getTranslatedRecipe(
          userAccount.appLanguage,
          EntityId(recipeId),
        );
        if (recipeTranslated == null) {
          safeEmit(recipe);
          return;
        }

        safeEmit(recipeTranslated);
      } else {
        safeEmit(recipe);
      }
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  final UserReceipeV2 recipe;
  final UserRecipeTranslateService _userRecipeTranslateService;
  final IUserAccountMetaDataRepository _userAccountMetaDataRepository;
  final IAuthUserService _authUserService;

  StreamSubscription? _subscription;
}
