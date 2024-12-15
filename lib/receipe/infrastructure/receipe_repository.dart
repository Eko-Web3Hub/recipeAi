import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository.dart';
import 'package:recipe_ai/utils/constant.dart';

class UserReceipeRepository implements IUserReceipeRepository {
  static const String baseUrl = "$baseApiUrl/gen-receipe-with-user-preference";

  static const String userReceipeCollection = "UserReceipe";

  final FirebaseFirestore _firestore;

  const UserReceipeRepository(this._firestore);

  @override
  Future<List<Receipe>> getReceipesBasedOnUserPreferencesFromApi(EntityId uid) {
    final apiRoute = "$baseUrl/${uid.value}";
    throw UnimplementedError();
  }

  @override
  Future<UserReceipe?> getReceipesBasedOnUserPreferencesFromFirestore(
    EntityId uid,
  ) async {
    final snapshot =
        await _firestore.collection(userReceipeCollection).doc(uid.value).get();

    if (snapshot.exists) {
      return null;
    }
    final data = snapshot.data()!;
  }

  @override
  Future<void> save(EntityId uid, UserReceipe userReceipe) {
    throw UnimplementedError();
  }
}
