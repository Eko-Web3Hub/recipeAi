import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/application/user_recipe_translate_service.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/user_account/domain/repositories/user_account_meta_data_repository.dart';
import 'package:recipe_ai/utils/functions.dart';
import 'package:recipe_ai/utils/safe_emit.dart';

class RecipeMetadataCardLoader extends Cubit<Receipe> {
  RecipeMetadataCardLoader(
    this.receipe,
    this._userRecipeTranslateService,
    this._userAccountMetaDataRepository,
    this._authUserService,
  ) : super(receipe) {
    _load();
  }

  void _load() {
    final recipeId = receipe.firestoreRecipeId?.value ??
        convertRecipeNameToFirestoreId(receipe.name);
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
          safeEmit(receipe);
          return;
        }

        safeEmit(recipeTranslated);
      } else {
        safeEmit(receipe);
      }
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  final Receipe receipe;
  final UserRecipeTranslateService _userRecipeTranslateService;
  final IUserAccountMetaDataRepository _userAccountMetaDataRepository;
  final IAuthUserService _authUserService;

  StreamSubscription? _subscription;
}
