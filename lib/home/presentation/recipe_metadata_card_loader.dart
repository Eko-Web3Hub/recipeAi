import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/safe_emit.dart';

class RecipeMetadataCardLoader extends Cubit<Receipe> {
  RecipeMetadataCardLoader(this.userRecipe, this._translationController)
    : super(
        _receipeFor(userRecipe, _translationController.currentLanguageEnum),
      ) {
    _translationController.addListener(_onLanguageChanged);
  }

  void _onLanguageChanged() {
    safeEmit(
      _receipeFor(userRecipe, _translationController.currentLanguageEnum),
    );
  }

  static Receipe _receipeFor(UserRecipeV2 userRecipe, AppLanguage language) =>
      language == AppLanguage.fr ? userRecipe.receipeFr : userRecipe.receipeEn;

  @override
  Future<void> close() {
    _translationController.removeListener(_onLanguageChanged);
    return super.close();
  }

  final UserRecipeV2 userRecipe;
  final TranslationController _translationController;
}
