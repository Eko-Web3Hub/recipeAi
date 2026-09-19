import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/fridge/domain/model/catalog_ingredient.dart';
import 'package:recipe_ai/fridge/domain/model/fridge_item.dart';
import 'package:recipe_ai/fridge/domain/model/fridge_unit.dart';
import 'package:recipe_ai/fridge/domain/repositories/fridge_repository.dart';
import 'package:recipe_ai/fridge/infrastructure/serialization/fridge_item_serialization.dart';

class FridgeRepository implements IFridgeRepository {
  static const String kitchenInventoryCollection = 'KitchenInventory';
  static const String ingredientsCollection = 'ingredients';
  static const String usualsCollection = 'usuals';

  final FirebaseFirestore _firestore;

  FridgeRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  DocumentReference<Map<String, dynamic>> _userDoc(EntityId uid) =>
      _firestore.collection(kitchenInventoryCollection).doc(uid.value);

  CollectionReference<Map<String, dynamic>> _items(EntityId uid) =>
      _userDoc(uid).collection(ingredientsCollection);

  @override
  Stream<List<FridgeItem>> watchItems(EntityId uid) => _items(uid)
      .orderBy('date', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) =>
                  FridgeItemSerialization.fromJson(doc.data(), docId: doc.id),
            )
            .toList(),
      );

  @override
  Future<FridgeItem> add(EntityId uid, FridgeItem item) async {
    final ref = _items(uid).doc();
    final added = item.copyWith(id: EntityId(ref.id), date: DateTime.now());

    final batch = _firestore.batch();
    batch.set(ref, FridgeItemSerialization.toJson(added));
    batch.set(
      _userDoc(uid).collection(usualsCollection).doc(added.nameKey),
      FridgeItemSerialization.usualToJson(added),
      SetOptions(merge: true),
    );
    await batch.commit();

    return added;
  }

  @override
  Future<void> update(EntityId uid, FridgeItem item) => _items(uid)
      .doc(item.id!.value)
      .set(FridgeItemSerialization.toJson(item), SetOptions(merge: true));

  @override
  Future<void> remove(EntityId uid, EntityId itemId) =>
      _items(uid).doc(itemId.value).delete();

  @override
  Future<void> restore(EntityId uid, FridgeItem item) =>
      _items(uid).doc(item.id!.value).set(FridgeItemSerialization.toJson(item));

  @override
  Stream<List<FridgeItem>> watchUsuals(EntityId uid, {int limit = 12}) =>
      _userDoc(uid)
          .collection(usualsCollection)
          .orderBy('count', descending: true)
          .limit(limit)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => FridgeItemSerialization.usualFromJson(doc.data()))
                .toList(),
          );
}

class IngredientCatalogRepository implements IIngredientCatalogRepository {
  static const String categoriesCollection = 'Categories';
  static const String ingredientsCollection = 'ingredients';

  final FirebaseFirestore _firestore;
  Future<List<CatalogIngredient>>? _catalog;

  IngredientCatalogRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  @override
  Future<List<CatalogIngredient>> loadCatalog() {
    return _catalog ??= _fetchCatalog().catchError((Object error) {
      // Let the next call retry instead of caching the failure.
      _catalog = null;
      throw error;
    });
  }

  Future<List<CatalogIngredient>> _fetchCatalog() async {
    final categories = await _firestore.collection(categoriesCollection).get();
    final ingredientsByCategory = await Future.wait(
      categories.docs.map(
        (category) =>
            category.reference.collection(ingredientsCollection).get(),
      ),
    );

    return [
      for (final snapshot in ingredientsByCategory)
        for (final doc in snapshot.docs) _catalogIngredient(doc.id, doc.data()),
    ];
  }

  static CatalogIngredient _catalogIngredient(
    String id,
    Map<String, dynamic> json,
  ) => CatalogIngredient(
    id: id,
    name: json['name'] as String? ?? '',
    nameFr: json['nameFr'] as String?,
    defaultUnit: FridgeUnit.fromKey(json['defaultUnit'] as String?),
    defaultAmount: (json['defaultAmount'] as num?)?.toDouble(),
    units: (json['units'] as List<dynamic>? ?? const [])
        .map((unit) => FridgeUnit.fromKey(unit as String?))
        .whereType<FridgeUnit>()
        .toList(),
    aliases: (json['aliases'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .toList(),
  );
}
