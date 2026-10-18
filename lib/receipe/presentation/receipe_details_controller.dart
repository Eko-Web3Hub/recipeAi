import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository_v2.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/constant.dart';

import 'package:recipe_ai/utils/safe_emit.dart';

class ReceipeDetailsState extends Equatable {
  const ReceipeDetailsState(this.reciepe, this.userReceipeV2);

  const ReceipeDetailsState.loading() : this(null, null);
  const ReceipeDetailsState.loaded(Receipe reciepe, UserRecipeV2 userReceipeV2)
    : this(reciepe, userReceipeV2);

  final Receipe? reciepe;
  final UserRecipeV2? userReceipeV2;

  @override
  List<Object?> get props => [reciepe, userReceipeV2];
}

class ReceipeDetailsController extends Cubit<ReceipeDetailsState> {
  ReceipeDetailsController(
    this.receipeId,
    this.seconds,
    this._translationController,
    this._userReceipeRepositoryV2,
  ) : super(const ReceipeDetailsState.loading()) {
    _loadRecipeUsingId();
  }

  ReceipeDetailsController.fromReceipe(
    UserRecipeV2 receipe,
    this._translationController,
    this._userReceipeRepositoryV2,
  ) : super(
        ReceipeDetailsState.loaded(
          _receipeFor(receipe, _translationController.currentLanguageEnum),
          receipe,
        ),
      ) {
    _load(receipe);
  }

  void _loadRecipeUsingId() async {
    log('Loading recipe using ID: $receipeId');
    final recipe = await _userReceipeRepositoryV2.getRecipeById(receipeId!);
    if (recipe == null) {
      log('No recipe found for ID: $receipeId');
      return;
    }
    safeEmit(
      ReceipeDetailsState.loaded(
        _receipeFor(recipe, _translationController.currentLanguageEnum),
        recipe,
      ),
    );
    _load(recipe);
  }

  /// Keeps the shown language in sync if the user changes it (e.g. from
  /// Settings) while this screen is open.
  void _load(UserRecipeV2 userRecipe) {
    _onLanguageChanged = () {
      safeEmit(
        ReceipeDetailsState.loaded(
          _receipeFor(userRecipe, _translationController.currentLanguageEnum),
          userRecipe,
        ),
      );
    };
    _translationController.addListener(_onLanguageChanged!);
  }

  static Receipe _receipeFor(UserRecipeV2 userRecipe, AppLanguage language) =>
      language == AppLanguage.fr ? userRecipe.receipeFr : userRecipe.receipeEn;

  @override
  Future<void> close() {
    if (_onLanguageChanged case final listener?) {
      _translationController.removeListener(listener);
    }
    return super.close();
  }

  int? seconds;
  EntityId? receipeId;
  final TranslationController _translationController;
  final IUserReceipeRepositoryV2 _userReceipeRepositoryV2;
  VoidCallback? _onLanguageChanged;
}
