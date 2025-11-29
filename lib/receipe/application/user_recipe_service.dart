import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository_v2.dart';

abstract class IUserRecipeService {
  Future<void> addToFavorite(UserReceipeV2 recipe);
  Future<void> removeFromFavorite(UserReceipeV2 recipe);
  Future<UserRecipeMetadata?> getUserRecipeMetadata(EntityId uid);
  Future<List<UserReceipeV2>> getAllUserRecipes();
  Future<void> saveUserReceipeMetadata(EntityId uid, DateTime lastUpdatedDate);
  Future<void> removeLastRecipesHomeUpdatedDate();
  Stream<bool> isReceiptSaved(EntityId receipeId);
  Stream<List<UserReceipeV2>> watchAllSavedReceipes();
}

class UserRecipeService implements IUserRecipeService {
  const UserRecipeService(
    this._userReceipeRepositoryV2,
    this._authUserService,
  );

  final IUserReceipeRepositoryV2 _userReceipeRepositoryV2;
  final IAuthUserService _authUserService;

  @override
  Future<void> addToFavorite(UserReceipeV2 recipe) =>
      _userReceipeRepositoryV2.saveUserReceipe(
        _authUserService.currentUser!.uid,
        recipe.addToFavorite(),
      );

  @override
  Future<void> removeFromFavorite(UserReceipeV2 recipe) =>
      _userReceipeRepositoryV2.saveUserReceipe(
        _authUserService.currentUser!.uid,
        recipe.removeFromFavorite(),
      );

  @override
  Stream<bool> isReceiptSaved(EntityId receipeId) => _userReceipeRepositoryV2
      .isReceiptSaved(_authUserService.currentUser!.uid, receipeId);

  @override
  Stream<List<UserReceipeV2>> watchAllSavedReceipes() =>
      _userReceipeRepositoryV2
          .watchAllSavedReceipes(_authUserService.currentUser!.uid);

  @override
  Future<UserRecipeMetadata?> getUserRecipeMetadata(EntityId uid) =>
      _userReceipeRepositoryV2.getUserRecipeMetadata(uid);

  @override
  Future<void> saveUserReceipeMetadata(
    EntityId uid,
    DateTime lastUpdatedDate,
  ) async {
    final metadata = await _userReceipeRepositoryV2.getUserRecipeMetadata(uid);
    if (metadata == null) {
      return _userReceipeRepositoryV2.saveUserReceipeMetadata(
        uid,
        UserRecipeMetadata(
          lastRecipesHomeUpdatedDate: lastUpdatedDate,
        ),
      );
    }

    return _userReceipeRepositoryV2.saveUserReceipeMetadata(
        uid,
        metadata.updateLastRecipesHomeUpdatedDate(
          lastUpdatedDate,
        ));
  }

  @override
  Future<void> removeLastRecipesHomeUpdatedDate() async {
    final uid = _authUserService.currentUser!.uid;

    final metadata =
        (await _userReceipeRepositoryV2.getUserRecipeMetadata(uid)) ??
            UserRecipeMetadata.initial();

    return _userReceipeRepositoryV2.saveUserReceipeMetadata(
      uid,
      metadata.removeLastRecipesHomeUpdatedDate(),
    );
  }

  @override
  Future<List<UserReceipeV2>> getAllUserRecipes() =>
      _userReceipeRepositoryV2.getAllUserRecipe(
        _authUserService.currentUser!.uid,
      );
}
