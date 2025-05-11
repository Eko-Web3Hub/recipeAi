import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/kitchen/application/retrieve_recipes_based_on_user_ingredient_and_preferences_usecase.dart';
import 'package:recipe_ai/kitchen/infrastructure/receipes_based_on_ingredient_user_preference_repository.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/utils/safe_emit.dart';

abstract class DisplayReceipesBasedOnIngredientUserPreferenceState
    extends Equatable {}

class DisplayReceipesBasedOnIngredientUserPreferenceLoading
    extends DisplayReceipesBasedOnIngredientUserPreferenceState {
  @override
  List<Object?> get props => [];
}

class DisplayReceipesBasedOnIngredientUserPreferenceLoaded
    extends DisplayReceipesBasedOnIngredientUserPreferenceState {
  DisplayReceipesBasedOnIngredientUserPreferenceLoaded(
    this.receipes,
  );

  @override
  List<Object?> get props => [receipes];

  final List<UserReceipeV2> receipes;
}

class DisplayReceipesBasedOnIngredientUserPreferenceError
    extends DisplayReceipesBasedOnIngredientUserPreferenceState {
  DisplayReceipesBasedOnIngredientUserPreferenceError(this.error);

  @override
  List<Object?> get props => [error];

  final GenRecipeErrorCode error;
}

class DisplayReceipesBasedOnIngredientUserPreferenceController
    extends Cubit<DisplayReceipesBasedOnIngredientUserPreferenceState> {
  DisplayReceipesBasedOnIngredientUserPreferenceController(
    this._authUserService,
    this._receipesBasedOnIngredientUserPreferenceUsecase,
  ) : super(DisplayReceipesBasedOnIngredientUserPreferenceLoading()) {
    _load();
  }

  Future<void> _load() async {
    final receipes =
        await _receipesBasedOnIngredientUserPreferenceUsecase.retrieve(
      _authUserService.currentUser!.uid,
    );

    return receipes.fold(
      (error) {
        safeEmit(
          DisplayReceipesBasedOnIngredientUserPreferenceError(error),
        );
      },
      (receipes) {
        safeEmit(
          DisplayReceipesBasedOnIngredientUserPreferenceLoaded(receipes),
        );
      },
    );
  }

  final IAuthUserService _authUserService;
  final RetrieveRecipesBasedOnUserIngredientAndPreferencesUsecase
      _receipesBasedOnIngredientUserPreferenceUsecase;
}
