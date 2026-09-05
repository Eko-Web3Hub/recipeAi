import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/shopping/domain/model/inventory_item.dart';
import 'package:recipe_ai/shopping/domain/model/item_status.dart';
import 'package:recipe_ai/shopping/domain/model/shopping_item.dart';
import 'package:recipe_ai/shopping/presentation/mock_data.dart';
import 'package:recipe_ai/shopping/presentation/shopping_state.dart';

class ShoppingController extends Cubit<ShoppingState> {
  ShoppingController() : super(const ShoppingState()) {
    _loadMockData();
  }

  void _loadMockData() {
    emit(state.copyWith(
      categories: mockCategories,
      inventoryItems: mockInventoryItems,
      shoppingItems: mockShoppingItems,
      suggestions: mockSuggestions,
      selectedCategoryId: 'all',
    ));
  }

  // Tab management
  void switchTab(ShoppingTab tab) => emit(state.copyWith(activeTab: tab));

  void toggleStoreMode() {
    final newStoreMode = !state.isStoreMode;
    emit(state.copyWith(
      isStoreMode: newStoreMode,
      activeTab: newStoreMode ? ShoppingTab.shoppingList : state.activeTab,
    ));
  }

  // Inventory tab
  void updateSearchQuery(String query) =>
      emit(state.copyWith(inventorySearchQuery: query));

  void selectCategory(String? categoryId) =>
      emit(state.copyWith(selectedCategoryId: categoryId));

  void incrementInventoryQuantity(String itemId) {
    final items = state.inventoryItems.map((item) {
      if (item.id == itemId) {
        final newQty = item.quantity + 1;
        return item.copyWith(
          quantity: newQty,
          status: _statusFromQuantity(newQty),
        );
      }
      return item;
    }).toList();
    emit(state.copyWith(inventoryItems: items));
  }

  void decrementInventoryQuantity(String itemId) {
    final items = state.inventoryItems.map((item) {
      if (item.id == itemId && item.quantity > 0) {
        final newQty = item.quantity - 1;
        return item.copyWith(
          quantity: newQty,
          status: _statusFromQuantity(newQty),
        );
      }
      return item;
    }).toList();
    emit(state.copyWith(inventoryItems: items));
  }

  void sendToShoppingList(String inventoryItemId) {
    final invItem =
        state.inventoryItems.firstWhere((i) => i.id == inventoryItemId);
    final existing = state.shoppingItems
        .where((s) => s.name.toLowerCase() == invItem.name.toLowerCase())
        .firstOrNull;

    if (existing != null) {
      // Increment quantity
      final updated = state.shoppingItems.map((s) {
        if (s.id == existing.id) {
          return s.copyWith(quantity: s.quantity + 1);
        }
        return s;
      }).toList();
      emit(state.copyWith(shoppingItems: updated));
    } else {
      final newItem = ShoppingItem(
        id: 'new_${DateTime.now().millisecondsSinceEpoch}',
        name: invItem.name,
        emoji: invItem.emoji,
        quantity: 1,
        unit: invItem.unit,
        categoryId: invItem.categoryId,
      );
      emit(state.copyWith(
          shoppingItems: [...state.shoppingItems, newItem]));
    }
  }

  // Shopping list tab
  void toggleShoppingItemChecked(String itemId) {
    final items = state.shoppingItems.map((item) {
      if (item.id == itemId) {
        return item.copyWith(isChecked: !item.isChecked);
      }
      return item;
    }).toList();
    emit(state.copyWith(shoppingItems: items));
  }

  void incrementShoppingQuantity(String itemId) {
    final items = state.shoppingItems.map((item) {
      if (item.id == itemId) {
        return item.copyWith(quantity: item.quantity + 1);
      }
      return item;
    }).toList();
    emit(state.copyWith(shoppingItems: items));
  }

  void decrementShoppingQuantity(String itemId) {
    final items = state.shoppingItems.where((item) {
      if (item.id == itemId && item.quantity <= 1) return false;
      return true;
    }).map((item) {
      if (item.id == itemId) {
        return item.copyWith(quantity: item.quantity - 1);
      }
      return item;
    }).toList();
    emit(state.copyWith(shoppingItems: items));
  }

  void addShoppingItem(String name) {
    if (name.trim().isEmpty) return;

    final existing = state.shoppingItems
        .where((s) => s.name.toLowerCase() == name.trim().toLowerCase())
        .firstOrNull;

    if (existing != null) {
      final updated = state.shoppingItems.map((s) {
        if (s.id == existing.id) {
          return s.copyWith(quantity: s.quantity + 1);
        }
        return s;
      }).toList();
      emit(state.copyWith(shoppingItems: updated));
    } else {
      final newItem = ShoppingItem(
        id: 'new_${DateTime.now().millisecondsSinceEpoch}',
        name: name.trim(),
        emoji: '\u{1F6D2}',
        quantity: 1,
        unit: 'pieces',
        categoryId: 'epicerie',
      );
      emit(state.copyWith(
          shoppingItems: [...state.shoppingItems, newItem]));
    }
  }

  void addSuggestionToList(String suggestionId) {
    final suggestion =
        state.suggestions.firstWhere((s) => s.id == suggestionId);
    final newItem = suggestion.copyWith(
      id: 'new_${DateTime.now().millisecondsSinceEpoch}',
    );
    emit(state.copyWith(
      shoppingItems: [...state.shoppingItems, newItem],
      suggestions: state.suggestions.where((s) => s.id != suggestionId).toList(),
    ));
  }

  void transferCheckedToInventory() {
    final checked = state.shoppingItems.where((i) => i.isChecked).toList();
    if (checked.isEmpty) return;

    // Update inventory items
    var updatedInventory = List<InventoryItem>.from(state.inventoryItems);
    for (final item in checked) {
      final existingIdx = updatedInventory
          .indexWhere((i) => i.name.toLowerCase() == item.name.toLowerCase());
      if (existingIdx >= 0) {
        final existing = updatedInventory[existingIdx];
        final newQty = existing.quantity + item.quantity;
        updatedInventory[existingIdx] = existing.copyWith(
          quantity: newQty,
          status: _statusFromQuantity(newQty),
        );
      } else {
        updatedInventory.add(InventoryItem(
          id: 'inv_${DateTime.now().millisecondsSinceEpoch}_${item.id}',
          name: item.name,
          emoji: item.emoji,
          quantity: item.quantity,
          unit: item.unit,
          status: _statusFromQuantity(item.quantity),
          categoryId: item.categoryId,
        ));
      }
    }

    // Remove checked items from shopping list
    final remaining = state.shoppingItems.where((i) => !i.isChecked).toList();

    emit(state.copyWith(
      inventoryItems: updatedInventory,
      shoppingItems: remaining,
      activeTab: ShoppingTab.inventory,
      isStoreMode: false,
    ));
  }

  ItemStatus _statusFromQuantity(int qty) {
    if (qty == 0) return ItemStatus.outOfStock;
    if (qty <= 2) return ItemStatus.lowStock;
    return ItemStatus.ok;
  }
}
