import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository_v2.dart';

abstract class IUserRecipeService {
  Future<void> addToFavorite(UserReceipeV2 recipe);
  Future<void> removeFromFavorite(UserReceipeV2 recipe);
  Stream<bool> isReceiptSaved(EntityId receipeId);
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
}
