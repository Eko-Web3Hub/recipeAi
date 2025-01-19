import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe.dart';

abstract class IUserReceipeRepository {
  Future<UserReceipe?> getReceipesBasedOnUserPreferencesFromFirestore(
    EntityId uid,
  );
  Future<List<Receipe>> getReceipesBasedOnUserPreferencesFromApi(EntityId uid);

  Future<void> save(EntityId uid, UserReceipe userReceipe);

  Future<void> deleteUserReceipe(EntityId uid);

  Stream<List<Receipe>> watchAllSavedReceipes(EntityId uid);

  Stream<UserReceipe?> watchUserReceipe(EntityId uid);

  Future<void> saveOneReceipt(EntityId uid, Receipe receipe);
  Future<bool> isOneReceiptSaved(EntityId uid, String receipeName);
  Stream<bool> isReceiptSaved(EntityId uid, String receipeName);

  Future<void> removeSavedReceipe(EntityId uid, String documentId);
}
