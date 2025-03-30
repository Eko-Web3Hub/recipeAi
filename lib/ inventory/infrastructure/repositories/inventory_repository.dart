import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_ai/%20inventory/domain/model/category.dart';
import 'package:recipe_ai/%20inventory/domain/repositories/inventory_repository.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';
import 'package:recipe_ai/receipe/infrastructure/serialization/ingredient_serialization.dart';

import '../serialization/category_serialization.dart';

class InventoryRepository implements IInventoryRepository {
  static const String categoriesCollections = "Categories";
  static const String ingredientsCollections = "ingredients";
  static const String kitchenInventoryCollection = "KitchenInventory";

  final FirebaseFirestore _firestore;

  InventoryRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Stream<List<Category>> getCategories() {
    return _firestore
        .collection(categoriesCollections)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // Ajouter l'ID du document dans le Map
        final data = doc.data();
        data['id'] = doc.id; // Ajoute l'ID du document Firestore
        return CategorySerialization.fromJson(data);
      }).toList();
    });
  }

  @override
  Stream<List<Ingredient>> getIngredients(String categoryId) {
    return _firestore
        .collection(categoriesCollections)
        .doc(categoryId)
        .collection(ingredientsCollections)
        .orderBy('name') // Tri alphabétique
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => IngredientSerialization.fromJson(doc.data()))
          .toList();
    });
  }

  @override
  Future<List<Ingredient>> searchIngredients(String query) async {
    List<Ingredient> results = [];
    final categoriesSnapshot =
        await _firestore.collection(categoriesCollections).get();
    for (var categoryDoc in categoriesSnapshot.docs) {
      final ingredientsSnapshot = await _firestore
          .collection(categoriesCollections)
          .doc(categoryDoc.id)
          .collection(ingredientsCollections)
          .get();

      for (var ingredientDoc in ingredientsSnapshot.docs) {
        results.add(IngredientSerialization.fromJson(ingredientDoc.data()));
      }
    }
    results = results.where(
      (element) {
        return element.name.toLowerCase().contains(query);
      },
    ).toList();
    return results;
  }
}
