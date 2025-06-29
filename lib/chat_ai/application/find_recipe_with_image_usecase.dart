import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository_v2.dart';

class FindRecipeWithImageUsecase {
  FindRecipeWithImageUsecase(
    this._userReceipeRepository,
    this._authUserService,
  );

  Future<UserReceipeV2> findRecipeWithImage(String recipePathImage) async {
    final uid = _authUserService.currentUser!.uid;
    final now = DateTime.now();
    final translatedRecipe = await _userReceipeRepository.findRecipeWithImage(
      recipePathImage,
    );
    final userRecipeUnsaved = UserReceipeV2(
      id: null,
      receipeFr: _fromRawRecipeFindWithImageToRecipe(
        translatedRecipe.recipeFr,
      ),
      receipeEn: _fromRawRecipeFindWithImageToRecipe(
        translatedRecipe.recipeEn,
      ),
      createdDate: now,
      isForHome: false,
      isAddedToFavorites: false,
    );
    final userRecipes = await _userReceipeRepository.save(
      uid,
      [userRecipeUnsaved],
    );

    return userRecipes.first;
  }

  final IUserReceipeRepositoryV2 _userReceipeRepository;
  final IAuthUserService _authUserService;
}

Receipe _fromRawRecipeFindWithImageToRecipe(RecipeFindWithImage recipe) =>
    Receipe(
      name: recipe.name,
      ingredients: recipe.ingredients,
      steps: recipe.steps,
      averageTime: recipe.averageTime,
      totalCalories: recipe.totalCalories,
    );
