import 'dart:developer';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository_v2.dart';
import 'package:recipe_ai/utils/safe_emit.dart';

abstract class IRecipeIdeasNavigation {
  void goToRecipeIdeas(List<UserRecipeV2> recipes);
}

abstract class GenerateRecipeWithIngredientPhotoState {}

class GenerateRecipeWithIngredientPhotoLoading
    extends GenerateRecipeWithIngredientPhotoState {}

class GenerateRecipeWithIngredientPhotoSuccess
    extends GenerateRecipeWithIngredientPhotoState {}

class GenerateRecipeWithIngredientPhotoFailure
    extends GenerateRecipeWithIngredientPhotoState {}

/// The backend responded successfully but found no recipe for the photo,
/// e.g. the ingredients weren't recognizable. Distinct from [Failure] so the
/// UI can point the user to retake the photo instead of a generic retry.
class GenerateRecipeWithIngredientPhotoEmpty
    extends GenerateRecipeWithIngredientPhotoState {}

class GenerateRecipeWithIngredientPhotoController
    extends Cubit<GenerateRecipeWithIngredientPhotoState> {
  GenerateRecipeWithIngredientPhotoController(
    this._navigation,
    this._userReceipeRepository,
    this._authUserService,
    this.file,
  ) : super(GenerateRecipeWithIngredientPhotoLoading()) {
    _load();
  }

  void retry() {
    emit(GenerateRecipeWithIngredientPhotoLoading());
    _load();
  }

  void _load() async {
    try {
      final uid = _authUserService.currentUser!.uid;
      final token = await _authUserService.getIdToken;
      if (token == null) {
        safeEmit(GenerateRecipeWithIngredientPhotoFailure());
        return;
      }

      final recipes = await _userReceipeRepository
          .genererateRecipesWithIngredientPicture(uid, token, file);
      if (recipes.isEmpty) {
        safeEmit(GenerateRecipeWithIngredientPhotoEmpty());
        return;
      }

      final userRecipesSaved = await _userReceipeRepository.save(uid, recipes);

      _navigation.goToRecipeIdeas(userRecipesSaved);
      safeEmit(GenerateRecipeWithIngredientPhotoSuccess());
    } catch (e) {
      log(
        'An error occurred while generating recipes with ingredient photo: $e',
      );
      safeEmit(GenerateRecipeWithIngredientPhotoFailure());
    }
  }

  final IRecipeIdeasNavigation _navigation;
  final IUserReceipeRepositoryV2 _userReceipeRepository;
  final IAuthUserService _authUserService;
  final File file;
}
