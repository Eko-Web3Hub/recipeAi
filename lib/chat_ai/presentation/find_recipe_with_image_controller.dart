import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/chat_ai/application/find_recipe_with_image_usecase.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/utils/safe_emit.dart';

abstract class FindRecipeWithImageState {}

class FindRecipeWithImageLoadingState extends FindRecipeWithImageState {}

class FindRecipeWithImageLoadedState extends FindRecipeWithImageState {
  final UserReceipeV2 userRecipe;

  FindRecipeWithImageLoadedState({
    required this.userRecipe,
  });
}

class FindRecipeWithImageErrorState extends FindRecipeWithImageState {
  final String errorMessage;

  FindRecipeWithImageErrorState(this.errorMessage);
}

class FindRecipeWithImageController extends Cubit<FindRecipeWithImageState?> {
  FindRecipeWithImageController(
    this._findRecipeWithImageUsecase,
  ) : super(null);

  Future<void> findRecipe(String recipePathImage) async {
    emit(FindRecipeWithImageLoadingState());
    final userRecipe = await _findRecipeWithImageUsecase.findRecipeWithImage(
      recipePathImage,
    );

    safeEmit(
      FindRecipeWithImageLoadedState(
        userRecipe: userRecipe,
      ),
    );
  }

  final FindRecipeWithImageUsecase _findRecipeWithImageUsecase;
}
