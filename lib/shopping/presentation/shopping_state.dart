import 'package:equatable/equatable.dart';
import 'package:recipe_ai/shopping/domain/model/inventory_item.dart';
import 'package:recipe_ai/shopping/domain/model/item_category.dart';
import 'package:recipe_ai/shopping/domain/model/shopping_item.dart';

enum ShoppingTab { inventory, shoppingList }

final class ShoppingState extends Equatable {
  const ShoppingState({
    this.activeTab = ShoppingTab.inventory,
    this.isStoreMode = false,
    this.inventoryItems = const [],
    this.inventorySearchQuery = '',
    this.selectedCategoryId,
    this.categories = const [],
    this.shoppingItems = const [],
    this.suggestions = const [],
  });

  final ShoppingTab activeTab;
  final bool isStoreMode;
  final List<InventoryItem> inventoryItems;
  final String inventorySearchQuery;
  final String? selectedCategoryId;
  final List<ItemCategory> categories;
  final List<ShoppingItem> shoppingItems;
  final List<ShoppingItem> suggestions;

  List<InventoryItem> get filteredInventoryItems {
    var items = List<InventoryItem>.from(inventoryItems);

    // Filter by category
    if (selectedCategoryId != null && selectedCategoryId != 'all') {
      items = items.where((i) => i.categoryId == selectedCategoryId).toList();
    }

    // Filter by search
    if (inventorySearchQuery.isNotEmpty) {
      final query = inventorySearchQuery.toLowerCase();
      items = items.where((i) => i.name.toLowerCase().contains(query)).toList();
    }

    // Sort: outOfStock -> lowStock -> ok
    items.sort((a, b) => a.status.index.compareTo(b.status.index));

    return items;
  }

  int get totalShoppingCount => shoppingItems.length;

  int get checkedCount => shoppingItems.where((i) => i.isChecked).length;

  bool get allChecked => shoppingItems.isNotEmpty && checkedCount == totalShoppingCount;

  double get progressPercent =>
      totalShoppingCount == 0 ? 0 : checkedCount / totalShoppingCount;

  Map<String, List<ShoppingItem>> get shoppingItemsByCategory {
    final map = <String, List<ShoppingItem>>{};
    for (final item in shoppingItems) {
      final categoryName = categories
          .where((c) => c.id == item.categoryId)
          .map((c) => c.name)
          .firstOrNull ?? item.categoryId;
      map.putIfAbsent(categoryName, () => []).add(item);
    }
    // Sort within each category: unchecked first
    for (final key in map.keys) {
      map[key]!.sort((a, b) {
        if (a.isChecked == b.isChecked) return 0;
        return a.isChecked ? 1 : -1;
      });
    }
    return map;
  }

  ShoppingState copyWith({
    ShoppingTab? activeTab,
    bool? isStoreMode,
    List<InventoryItem>? inventoryItems,
    String? inventorySearchQuery,
    String? selectedCategoryId,
    List<ItemCategory>? categories,
    List<ShoppingItem>? shoppingItems,
    List<ShoppingItem>? suggestions,
  }) {
    return ShoppingState(
      activeTab: activeTab ?? this.activeTab,
      isStoreMode: isStoreMode ?? this.isStoreMode,
      inventoryItems: inventoryItems ?? this.inventoryItems,
      inventorySearchQuery: inventorySearchQuery ?? this.inventorySearchQuery,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      categories: categories ?? this.categories,
      shoppingItems: shoppingItems ?? this.shoppingItems,
      suggestions: suggestions ?? this.suggestions,
    );
  }

  @override
  List<Object?> get props => [
        activeTab,
        isStoreMode,
        inventoryItems,
        inventorySearchQuery,
        selectedCategoryId,
        categories,
        shoppingItems,
        suggestions,
      ];
}
