import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/fridge/domain/model/fridge_item.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository_v2.dart';
import 'package:recipe_ai/utils/safe_emit.dart';

abstract class GenerateRecipeFromFridgeSelectionState {}

class GenerateRecipeFromFridgeSelectionIdle
    extends GenerateRecipeFromFridgeSelectionState {}

class GenerateRecipeFromFridgeSelectionLoading
    extends GenerateRecipeFromFridgeSelectionState {}

/// Fewer available ingredients were selected than the backend needs for a
/// meaningful suggestion — distinct from [GenerateRecipeFromFridgeSelectionFailure]
/// so the UI can say exactly how many more to pick instead of a generic error.
class GenerateRecipeFromFridgeSelectionNotEnoughIngredients
    extends GenerateRecipeFromFridgeSelectionState {
  GenerateRecipeFromFridgeSelectionNotEnoughIngredients({
    required this.minimum,
    required this.provided,
  });

  final int minimum;
  final int provided;
}

class GenerateRecipeFromFridgeSelectionFailure
    extends GenerateRecipeFromFridgeSelectionState {}

/// "Mon frigo"'s own "Générer ma recette" button: generates from whichever
/// [FridgeItem]s are currently checked, rather than the whole fridge. Success
/// is reported through [onGenerated] (navigation) rather than a state, same
/// reasoning as [GenerateRecipeFromFridgeSelectionIdle] being the resting
/// state afterwards — the button stays on the fridge screen, it doesn't own
/// a result screen the way the photo flow's bottom sheet does.
class GenerateRecipeFromFridgeSelectionController
    extends Cubit<GenerateRecipeFromFridgeSelectionState> {
  GenerateRecipeFromFridgeSelectionController(
    this._userReceipeRepository,
    this._authUserService,
    this.onGenerated,
  ) : super(GenerateRecipeFromFridgeSelectionIdle());

  final IUserReceipeRepositoryV2 _userReceipeRepository;
  final IAuthUserService _authUserService;
  final void Function(List<UserRecipeV2> recipes) onGenerated;

  Future<void> generate(List<FridgeItem> selectedIngredients) async {
    safeEmit(GenerateRecipeFromFridgeSelectionLoading());
    try {
      final uid = _authUserService.currentUser!.uid;
      final token = await _authUserService.getIdToken;
      if (token == null) {
        safeEmit(GenerateRecipeFromFridgeSelectionFailure());
        return;
      }

      final recipes = await _userReceipeRepository
          .generateRecipesWithIngredientList(uid, token, selectedIngredients);
      final userRecipesSaved = await _userReceipeRepository.save(
        uid,
        recipes,
      );

      safeEmit(GenerateRecipeFromFridgeSelectionIdle());
      onGenerated(userRecipesSaved);
    } on NotEnoughIngredientsException catch (e) {
      safeEmit(
        GenerateRecipeFromFridgeSelectionNotEnoughIngredients(
          minimum: e.minimum,
          provided: e.provided,
        ),
      );
    } catch (e) {
      log('An error occurred while generating a recipe from the fridge selection: $e');
      safeEmit(GenerateRecipeFromFridgeSelectionFailure());
    }
  }
}
