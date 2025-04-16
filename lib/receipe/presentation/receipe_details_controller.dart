import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/application/user_recipe_translate_service.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/user_account/domain/repositories/user_account_meta_data_repository.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/functions.dart';
import 'package:recipe_ai/utils/safe_emit.dart';

class ReceipeDetailsState extends Equatable {
  const ReceipeDetailsState(
    this.reciepe,
  );

  const ReceipeDetailsState.loading() : this(null);
  const ReceipeDetailsState.loaded(
    Receipe reciepe,
  ) : this(
          reciepe,
        );

  final Receipe? reciepe;

  @override
  List<Object?> get props => [reciepe];
}

class ReceipeDetailsController extends Cubit<ReceipeDetailsState> {
  ReceipeDetailsController(
    this.receipeId,
    this.seconds,
    this._userRecipeTranslateService,
    this._authUserService,
    this._userAccountMetaDataRepository,
  ) : super(
          const ReceipeDetailsState.loading(),
        ) {
    _load(receipeSample);
  }

  ReceipeDetailsController.fromReceipe(
    Receipe receipe,
    this._userRecipeTranslateService,
    this._authUserService,
    this._userAccountMetaDataRepository,
  ) : super(
          ReceipeDetailsState.loaded(receipe),
        ) {
    _load(receipe);
  }

  void _load(Receipe recipe) async {
    final recipeName = convertRecipeNameToFirestoreId(recipe.name);

    _subscription = _userAccountMetaDataRepository
        .watchUserAccount(_authUserService.currentUser!.uid)
        .listen((userAccount) async {
      if (userAccount != null) {
        final recipeId = convertRecipeNameToFirestoreId(recipe.name);
        final recipeTranslated =
            await _userRecipeTranslateService.getTranslatedRecipe(
          userAccount.appLanguage,
          EntityId(recipeId),
        );
        if (recipeTranslated == null) {
          safeEmit(
            ReceipeDetailsState.loaded(recipe),
          );
          return;
        }

        safeEmit(
          ReceipeDetailsState.loaded(
            recipeTranslated,
          ),
        );
      } else {
        ReceipeDetailsState.loaded(recipe);
      }
    });

    _subscription = _userRecipeTranslateService
        .watchTranslatedRecipe(
      recipeName: recipeName,
    )
        .listen(
      (event) {
        if (event != null) {
          safeEmit(
            ReceipeDetailsState.loaded(
              event,
            ),
          );
        }
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  int? seconds;
  EntityId? receipeId;
  final UserRecipeTranslateService _userRecipeTranslateService;
  final IAuthUserService _authUserService;
  final IUserAccountMetaDataRepository _userAccountMetaDataRepository;
  StreamSubscription? _subscription;
}
