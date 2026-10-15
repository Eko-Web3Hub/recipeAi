import 'package:equatable/equatable.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/fridge/domain/model/fridge_item.dart';

/// An ingredient to buy (`ShoppingLists/{listId}/items/{id}`).
///
/// The ingredient itself is a [FridgeItem]: a bought item goes to the fridge
/// as is, and the fridge quantity sheet, merge and search rules apply.
///
/// A [checked] item is in the cart: it stays in the list ("Déjà acheté")
/// until a member moves the checked items to their fridge.
class ShoppingItem extends Equatable {
  const ShoppingItem({
    required this.ingredient,
    this.categoryId,
    this.addedBy,
    this.checked = false,
    this.checkedBy,
  });

  final FridgeItem ingredient;

  /// Catalog category of the ingredient, its aisle. Null for a custom
  /// ingredient: it goes to "Others".
  final String? categoryId;

  /// The member who added the item.
  final EntityId? addedBy;

  final bool checked;

  /// The member who checked the item.
  final EntityId? checkedBy;

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
    checked: checked,
    checkedBy: checkedBy,
  );

  ShoppingItem withChecked(bool checked, {EntityId? by}) => ShoppingItem(
    ingredient: ingredient,
    categoryId: categoryId,
    addedBy: addedBy,
    checked: checked,
    checkedBy: checked ? by : null,
  );

  @override
  List<Object?> get props => [
    ingredient,
    categoryId,
    addedBy,
    checked,
    checkedBy,
  ];
}
