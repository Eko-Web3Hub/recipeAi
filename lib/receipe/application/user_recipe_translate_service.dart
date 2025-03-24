import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_recipe_translate.dart';

import '../../user_account/presentation/translation_controller.dart';

class UserRecipeTranslateService {
  UserRecipeTranslateService(
    this._authUserService,
    this._translationController,
    this._userRecipeTranslateRepository,
  );

  UserRecipeTranslateService.inject()
      : this(
          di<IAuthUserService>(),
          di<TranslationController>(),
          di<IUserRecipeTranslateRepository>(),
        );

  Stream<Receipe?> watchTranslatedRecipe({
    required String recipeName,
  }) {
    final uid = _authUserService.currentUser!.uid;

    return _userRecipeTranslateRepository.watchTranslatedRecipe(
      recipeName: EntityId(recipeName),
      uid: uid,
      language: _translationController.currentLanguageEnum,
    );
  }

  final IAuthUserService _authUserService;
  final TranslationController _translationController;
  final IUserRecipeTranslateRepository _userRecipeTranslateRepository;
}
