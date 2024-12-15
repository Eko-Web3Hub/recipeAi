import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository.dart';
import 'package:recipe_ai/utils/constant.dart';

class UserReceipeRepository implements IUserReceipeRepository {
  static const String baseUrl = "$baseApiUrl/gen-receipe-with-user-preference";

  @override
  Future<List<Receipe>> getReceipesBasedOnUserPreferencesFromApi(EntityId uid) {
    final apiRoute = "$baseUrl/${uid.value}";
    throw UnimplementedError();
  }

  @override
  Future<UserReceipe> getReceipesBasedOnUserPreferencesFromFirestore(
      EntityId uid) {
    throw UnimplementedError();
  }

  @override
  Future<void> save(EntityId uid, UserReceipe userReceipe) {
    throw UnimplementedError();
  }
}
