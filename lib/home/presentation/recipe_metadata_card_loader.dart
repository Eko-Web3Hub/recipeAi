import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/user_account/domain/repositories/user_account_meta_data_repository.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/safe_emit.dart';

class RecipeMetadataCardLoader extends Cubit<Receipe> {
  RecipeMetadataCardLoader(
    this.userRecipe,
    this._userAccountMetaDataRepository,
    this._authUserService,
  ) : super(userRecipe.receipeEn) {
    _load();
  }

  void _load() {
    _subscription = _userAccountMetaDataRepository
        .watchUserAccount(_authUserService.currentUser!.uid)
        .listen((userAccount) async {
      if (userAccount != null) {
        if (userAccount.appLanguage == AppLanguage.fr) {
          safeEmit(userRecipe.receipeFr);
        } else if (userAccount.appLanguage == AppLanguage.en) {
          safeEmit(userRecipe.receipeEn);
        } else {
          throw Exception(
            'Unsupported language: ${userAccount.appLanguage}',
          );
        }
      } else {
        // If user account is null, emit the recipe in English by default
        safeEmit(userRecipe.receipeEn);
      }
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  final UserReceipeV2 userRecipe;
  final IUserAccountMetaDataRepository _userAccountMetaDataRepository;
  final IAuthUserService _authUserService;

  StreamSubscription? _subscription;
}
