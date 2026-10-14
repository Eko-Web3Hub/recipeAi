import 'package:equatable/equatable.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/fridge/domain/model/fridge_item.dart';

/// An ingredient to buy (`ShoppingLists/{listId}/items/{id}`).
///
/// The ingredient itself is a [FridgeItem]: a bought item goes to the fridge
/// as is, and the fridge quantity sheet, merge and search rules apply.
class ShoppingItem extends Equatable {
  const ShoppingItem({required this.ingredient, this.categoryId, this.addedBy});

  final FridgeItem ingredient;

  /// Catalog category of the ingredient, its aisle. Null for a custom
  /// ingredient: it goes to "Others".
  final String? categoryId;

  /// The member who added the item.
  final EntityId? addedBy;

  EntityId? get id => ingredient.id;

  /// The ingredient to put in the fridge once bought.
  FridgeItem get fridgeDraft => FridgeItem.draft(
    name: ingredient.name,
    nameFr: ingredient.nameFr,
    amount: ingredient.amount,
    unit: ingredient.unit,
    catalogId: ingredient.catalogId,
  );

  ShoppingItem withIngredient(FridgeItem ingredient) => ShoppingItem(
    ingredient: ingredient,
    categoryId: categoryId,
    addedBy: addedBy,
  );

  @override
  List<Object?> get props => [ingredient, categoryId, addedBy];
}
