import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/receipe/domain/model/user_finished_recipe.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository_v2.dart';
import 'package:recipe_ai/utils/safe_emit.dart';

abstract class CookModeState extends Equatable {
  const CookModeState();
  @override
  List<Object> get props => [];
}

class CookModeStateInitial extends CookModeState {
  const CookModeStateInitial();
}

class CookModeStateFinished extends CookModeState {
  const CookModeStateFinished();
}

class CookModeStateUserNotConnectedError extends CookModeState {
  const CookModeStateUserNotConnectedError();

  @override
  List<Object> get props => [];
}

class CookModeController extends Cubit<CookModeState> {
  CookModeController(this._authUserService, this._userReceipeRepositoryV2)
    : super(const CookModeStateInitial());

  CookModeController.inject()
    : this(di<IAuthUserService>(), di<IUserReceipeRepositoryV2>());

  final IAuthUserService _authUserService;
  final IUserReceipeRepositoryV2 _userReceipeRepositoryV2;

  void markAsCooked(EntityId recipeId, int recipeNote) {
    final uid = _authUserService.currentUser?.uid;
    if (uid == null) {
      safeEmit(const CookModeStateUserNotConnectedError());
      return;
    }

    _userReceipeRepositoryV2.markRecipeAsFinished(
      uid: uid,
      recipe: UserFinishedRecipe(recipeId: recipeId, note: recipeNote),
    );

    safeEmit(CookModeStateFinished());
  }
}
