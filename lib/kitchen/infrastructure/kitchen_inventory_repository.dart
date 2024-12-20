import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/kitchen/domain/repositories/kitchen_inventory_repository.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';
import 'package:recipe_ai/receipe/infrastructure/serialization/ingredient_serialization.dart';

class KitchenInventoryRepository implements IKitchenInventoryRepository {

    static const String kitchenInventoryCollection = "KitchenInventory";

  final FirebaseFirestore _firestore;

  KitchenInventoryRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  @override
  Future<List<Ingredient>> getIngredientsAddedByUser(EntityId uid) async {
    final snapshot = await _firestore.collection(kitchenInventoryCollection).doc(uid.value).get();

    if (!snapshot.exists) {
      return [];
    }
    final data = snapshot.data()!;

    return data["ingredients"].map<Ingredient>((ingredient) => IngredientSerialization.fromJson(ingredient)).toList();
  }

  @override
  Future<void> save(EntityId uid, Ingredient ingredient) {
    return _firestore.collection(kitchenInventoryCollection).doc(uid.value).set(
      {
        "ingredients": FieldValue.arrayUnion([IngredientSerialization.toJson(ingredient)])
      },
      SetOptions(merge: true),
    );
  }
}