import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/saved_receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe.dart';

abstract class IUserReceipeRepository {
  Future<UserReceipe?> getReceipesBasedOnUserPreferencesFromFirestore(
    EntityId uid,
  );
  Future<List<Receipe>> getReceipesBasedOnUserPreferencesFromApi(EntityId uid);

  Future<void> save(EntityId uid, UserReceipe userReceipe);

  Stream<List<SavedReceipe>> watchAllSavedReceipes(EntityId uid);

   Future<void> saveOneReceipt(EntityId uid,int index ,Receipe receipe);
   Future<bool> isOneReceiptSaved(EntityId uid,int index);

    Future<void> removeSavedReceipe(EntityId uid,String documentId);


}
