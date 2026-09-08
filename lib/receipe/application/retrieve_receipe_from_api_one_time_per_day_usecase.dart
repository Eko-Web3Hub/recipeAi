import 'dart:developer';

import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/application/user_recipe_service.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository_v2.dart';
import 'package:recipe_ai/utils/local_storage_repo.dart';

class RetrieveReceipeException implements Exception {
  const RetrieveReceipeException();
}

class UserNotAuthenticatedException implements Exception {
  const UserNotAuthenticatedException();
}

/// Compares calendar days (year/month/day) rather than elapsed duration,
/// so the "once per day" gate resets at midnight instead of after a
/// rolling 24h window.
bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

class RetrieveReceipeFromApiOneTimePerDayUsecase {
  final IAuthUserService _authUserService;
  final IUserReceipeRepositoryV2 _userReceipeRepositoryV2;
  final IUserRecipeService _userRecipeService;
  final ILocalStorageRepository _localStorageRepository;

  const RetrieveReceipeFromApiOneTimePerDayUsecase(
    this._authUserService,
    this._userReceipeRepositoryV2,
    this._userRecipeService,
    this._localStorageRepository,
  );

  Future<List<UserRecipeV2>> retrieve(DateTime now) async {
    try {
      final uid = _authUserService.currentUser?.uid;
      if (uid == null) {
        throw const UserNotAuthenticatedException();
      }
      final userRecipeMetadata = await _userRecipeService.getUserRecipeMetadata(
        uid,
      );

      if (userRecipeMetadata == null ||
          userRecipeMetadata.lastRecipesHomeUpdatedDate == null) {
        /// `await` is required here: without it the future escapes the
        /// try/catch and the error is never converted to
        /// [RetrieveReceipeException].
        return await _retrieveAndSaveOnLocalStorage(uid, now);
      }

      final lastUpdatedDate = userRecipeMetadata.lastRecipesHomeUpdatedDate;

      if (!_isSameDay(now, lastUpdatedDate!)) {
        final receipes = await _retrieveAndSaveOnLocalStorage(uid, now);

        return receipes;
      } else {
        /// Just retrieve the recipes from local storage if they were already
        /// refreshed today
        final suggestedRecipes = await _localStorageRepository
            .getSuggestedRecipes();

        return suggestedRecipes ?? [];
      }
    } on UserNotAuthenticatedException {
      rethrow;
    } catch (e) {
      log('Failed to retrieve recipes: $e');
      throw const RetrieveReceipeException();
    }
  }

  Future<List<UserRecipeV2>> _retrieveAndSaveOnLocalStorage(
    EntityId uid,
    DateTime now,
  ) async {
    final token = await _authUserService.getIdToken;
    if (token == null) {
      throw const UserNotAuthenticatedException();
    }

    final suggestedRecipes = await _userReceipeRepositoryV2.suggestedRecipes(
      uid,
      token,
    );

    await _localStorageRepository.setSuggestedRecipes(suggestedRecipes);
    await _userRecipeService.saveUserReceipeMetadata(uid, now);

    return suggestedRecipes;
  }
}
