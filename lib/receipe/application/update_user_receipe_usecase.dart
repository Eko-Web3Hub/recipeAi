import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository.dart';

class UpdateUserReceipeUsecase {
  final IUserReceipeRepository _userReceipeRepository;
  final IAuthUserService _authUserService;

  const UpdateUserReceipeUsecase(
    this._userReceipeRepository,
    this._authUserService,
  );

  Future<void> update(DateTime now) async {
    final uid = _authUserService.currentUser!.uid;
    final receipes = await _userReceipeRepository
        .getReceipesBasedOnUserPreferencesFromApi(uid);

    return _userReceipeRepository.save(
      uid,
      UserReceipe(
        receipes: receipes,
        lastUpdatedDate: now,
      ),
    );
  }
}
