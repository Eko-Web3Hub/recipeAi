import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/fridge/domain/model/catalog_ingredient.dart';
import 'package:recipe_ai/fridge/domain/model/fridge_item.dart';

abstract class IFridgeRepository {
  /// Fridge content, newest first.
  Stream<List<FridgeItem>> watchItems(EntityId uid);

  /// Adds [item] and records it in the user's usual ingredients.
  /// Returns the item with its generated id.
  Future<FridgeItem> add(EntityId uid, FridgeItem item);

  Future<void> update(EntityId uid, FridgeItem item);

  Future<void> remove(EntityId uid, EntityId itemId);

  /// Writes back a removed [item] under its former id (undo).
  Future<void> restore(EntityId uid, FridgeItem item);

  /// The user's most added ingredients, most frequent first.
  Stream<List<FridgeItem>> watchUsuals(EntityId uid, {int limit});
}

abstract class IIngredientCatalogRepository {
  /// Every catalog ingredient. Loaded once, then served from memory.
  Future<List<CatalogIngredient>> loadCatalog();
}
