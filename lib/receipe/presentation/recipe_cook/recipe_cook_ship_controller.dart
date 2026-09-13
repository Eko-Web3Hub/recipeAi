import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/receipe/domain/model/user_finished_recipe.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository_v2.dart';
import 'package:recipe_ai/utils/safe_emit.dart';

class RecipeCookShipController extends Cubit<RecipeCookedSummary?> {
  final IAuthUserService _authUserService;
  final IUserReceipeRepositoryV2 _receipeRepositoryV2;

  RecipeCookShipController(
    this._authUserService,
    this._receipeRepositoryV2, {
    required EntityId recipeId,
  }) : super(null) {
    _load(recipeId);
  }

  RecipeCookShipController.inject({required EntityId recipeId})
    : this(
        di<IAuthUserService>(),
        di<IUserReceipeRepositoryV2>(),
        recipeId: recipeId,
      );

  void _load(EntityId recipeId) {
    final uid = _authUserService.currentUser?.uid;
    if (uid == null) {
      safeEmit(null);
      return;
    }

    _recipeCookedSummary = _receipeRepositoryV2
        .recipeCookedSummary(uid: uid, recipeId: recipeId)
        .listen((summary) {
          safeEmit(summary);
        });
  }

  @override
  Future<void> close() {
    _recipeCookedSummary?.cancel();

    return super.close();
  }

  StreamSubscription<RecipeCookedSummary?>? _recipeCookedSummary;
}
