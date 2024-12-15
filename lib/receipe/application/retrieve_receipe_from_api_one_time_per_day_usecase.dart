import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository.dart';
import 'package:recipe_ai/utils/app_text.dart';

class RetrieveReceipeException implements Exception {
  final String message;

  const RetrieveReceipeException(this.message);
}

class RetrieveReceipeFromApiOneTimePerDayUsecase {
  final IUserReceipeRepository _userReceipeRepository;
  final IAuthUserService _authUserService;

  const RetrieveReceipeFromApiOneTimePerDayUsecase(
    this._userReceipeRepository,
    this._authUserService,
  );

  Future<List<Receipe>> retrieve(DateTime now) async {
    try {
      final uid = EntityId(_authUserService.currentUser!.uid);
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
      throw const RetrieveReceipeException(
        AppText.receipeRetrievalError,
      );
    }
  }

  Future<List<Receipe>> _retrieveAndSave(EntityId uid, DateTime now) async {
    final receipes = await _userReceipeRepository
        .getReceipesBasedOnUserPreferencesFromApi(uid);

    _userReceipeRepository.save(
      uid,
      UserReceipe(
        receipes: receipes,
        lastUpdatedDate: now,
      ),
    );

    return receipes;
  }
}
