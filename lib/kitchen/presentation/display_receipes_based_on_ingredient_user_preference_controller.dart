import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/utils/safe_emit.dart';

import '../domain/repositories/receipes_based_on_ingredient_user_preference_repository.dart';

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

  final List<Receipe> receipes;
}

class DisplayReceipesBasedOnIngredientUserPreferenceController
    extends Cubit<DisplayReceipesBasedOnIngredientUserPreferenceState> {
  DisplayReceipesBasedOnIngredientUserPreferenceController(
    this._authUserService,
    this._receipesBasedOnIngredientUserPreferenceRepository,
  ) : super(DisplayReceipesBasedOnIngredientUserPreferenceLoading()) {
    _load();
  }

  Future<void> _load() async {
    final receipes = await _receipesBasedOnIngredientUserPreferenceRepository
        .getReceipesBasedOnIngredientUserPreference(
      _authUserService.currentUser!.uid,
    );
    safeEmit(
      DisplayReceipesBasedOnIngredientUserPreferenceLoaded(receipes),
    );
  }

  final IAuthUserService _authUserService;
  final IReceipesBasedOnIngredientUserPreferenceRepository
      _receipesBasedOnIngredientUserPreferenceRepository;
}
