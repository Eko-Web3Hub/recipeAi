import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_recipe_translate.dart';
import 'package:recipe_ai/user_account/domain/repositories/user_account_meta_data_repository.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/functions.dart';

class RetrieveReceipeException implements Exception {
  const RetrieveReceipeException();
}

class RetrieveReceipeFromApiOneTimePerDayUsecase {
  final IUserReceipeRepository _userReceipeRepository;
  final IAuthUserService _authUserService;
  final IUserRecipeTranslateRepository _userRecipeTranslateRepository;
  final IUserAccountMetaDataRepository _userAccountMetaDataRepository;

  const RetrieveReceipeFromApiOneTimePerDayUsecase(
    this._userReceipeRepository,
    this._authUserService,
    this._userRecipeTranslateRepository,
    this._userAccountMetaDataRepository,
  );

  Future<List<Receipe>> retrieve(DateTime now) async {
    try {
      final uid = _authUserService.currentUser!.uid;
      final currentUserReceipe = await _userReceipeRepository
          .getReceipesBasedOnUserPreferencesFromFirestore(uid);

      if (currentUserReceipe == null) {
        final receipes = await _retrieveAndSave(uid, now);

        return receipes;
      }

      final lastUpdatedDate = currentUserReceipe.lastUpdatedDate;

      if (now.difference(lastUpdatedDate).inDays >= 1) {
        final receipes = await _retrieveAndSave(uid, now);

        return receipes;
      } else {
        return currentUserReceipe.receipes;
      }
    } catch (e) {
      throw const RetrieveReceipeException();
    }
  }

  Future<List<Receipe>> _retrieveAndSave(
    EntityId uid,
    DateTime now,
  ) async {
    final receipes = await _userReceipeRepository
        .getReceipesBasedOnUserPreferencesFromApi(uid);
    final userSetting =
        await _userAccountMetaDataRepository.getUserAccount(uid);
    final defaultLanguage = userSetting?.appLanguage ?? AppLanguage.en;
    final recipesEnWithFirestoreId = receipes.recipesEn
        .map(
          (e) => e.assignFirestoreRecipeId(
            EntityId(
              convertRecipeNameToFirestoreId(e.name),
            ),
          ),
        )
        .toList();

    _userReceipeRepository.save(
      uid,
      UserReceipe(
        receipes: recipesEnWithFirestoreId,
        lastUpdatedDate: now,
      ),
    );
    final recipesWithFirestoreId = <Receipe>[];

    for (var i = 0; i < receipes.recipesEn.length; i++) {
      final recipe = receipes.recipesFr[i].assignFirestoreRecipeId(
        EntityId(
          convertRecipeNameToFirestoreId(receipes.recipesEn[i].name),
        ),
      );
      recipesWithFirestoreId.add(recipe);
    }

    _userRecipeTranslateRepository.saveTranslatedRecipes(
      uid: uid,
      language: AppLanguage.fr,
      receipes: recipesWithFirestoreId,
    );

    _userRecipeTranslateRepository.saveTranslatedRecipes(
      uid: uid,
      language: AppLanguage.en,
      receipes: recipesEnWithFirestoreId,
    );

    return defaultLanguage == AppLanguage.en
        ? receipes.recipesEn
        : receipes.recipesFr;
  }
}
