import 'dart:developer';

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
  DisplayReceipesBasedOnIngredientUserPreferenceLoaded(this.receipes);

  @override
  List<Object?> get props => [receipes];

  final List<UserRecipeV2> receipes;
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
    load();
  }

  /// Also used by the retry button of the error screen.
  Future<void> load() async {
    if (state is! DisplayReceipesBasedOnIngredientUserPreferenceLoading) {
      safeEmit(DisplayReceipesBasedOnIngredientUserPreferenceLoading());
    }

    try {
      final receipes = await _receipesBasedOnIngredientUserPreferenceUsecase
          .retrieve(_authUserService.currentUser!.uid);

      receipes.fold(
        (error) {
          safeEmit(DisplayReceipesBasedOnIngredientUserPreferenceError(error));
        },
        (receipes) {
          safeEmit(
            DisplayReceipesBasedOnIngredientUserPreferenceLoaded(receipes),
          );
        },
      );
    } catch (e) {
      // Whatever fails on the way (network, parsing, saving the recipes), the
      // screen must leave its loader for the error and its retry button.
      log('Recipe generation failed: $e');
      safeEmit(
        DisplayReceipesBasedOnIngredientUserPreferenceError(
          GenRecipeErrorCode.internalServerError,
        ),
      );
    }
  }

  final IAuthUserService _authUserService;
  final RetrieveRecipesBasedOnUserIngredientAndPreferencesUsecase
  _receipesBasedOnIngredientUserPreferenceUsecase;
}
