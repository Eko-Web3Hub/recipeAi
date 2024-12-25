import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/kitchen/domain/repositories/kitchen_inventory_repository.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';
import 'package:recipe_ai/receipe/infrastructure/serialization/ingredient_serialization.dart';

class KitchenInventoryRepository implements IKitchenInventoryRepository {
  static const String kitchenInventoryCollection = "KitchenInventory";
  static const String ingredientsCollection = "ingredients";

  final FirebaseFirestore _firestore;

  KitchenInventoryRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Stream<List<Ingredient>> watchIngredientsAddedByUser(EntityId uid) {
    return _firestore
        .collection(kitchenInventoryCollection)
        .doc(uid.value)
        .collection(ingredientsCollection)
        .orderBy("date", descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map<Ingredient>(
            (doc) => IngredientSerialization.fromJson(doc.data()),
          )
          .toList();
    });
  }

  @override
  Future<void> save(EntityId uid, Ingredient ingredient) {
    return _firestore
        .collection(kitchenInventoryCollection)
        .doc(uid.value)
        .collection(ingredientsCollection)
        .add(IngredientSerialization.toJson(ingredient));
  }

  @override
  Future<List<Ingredient>> searchForIngredients(
    EntityId uid,
    String query,
  ) async {
    final ingredients = await getIngredientsAddedByUser(uid);
    return ingredients
        .where((ingredient) =>
            ingredient.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<List<Ingredient>> getIngredientsAddedByUser(EntityId uid) {
    return _firestore
        .collection(kitchenInventoryCollection)
        .doc(uid.value)
        .collection(ingredientsCollection)
        .get()
        .then((snapshot) {
      return snapshot.docs
          .map<Ingredient>(
            (doc) => IngredientSerialization.fromJson(doc.data()),
          )
          .toList();
    });
  }
}
