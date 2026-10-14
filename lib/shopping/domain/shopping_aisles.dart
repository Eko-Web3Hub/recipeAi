import 'package:equatable/equatable.dart';
import 'package:recipe_ai/fridge/domain/model/catalog_category.dart';
import 'package:recipe_ai/shopping/domain/model/shopping_item.dart';

/// The items of one aisle. A null [category] is the "Others" aisle.
class AisleSection extends Equatable {
  const AisleSection({required this.category, required this.items});

  final CatalogCategory? category;
  final List<ShoppingItem> items;

  @override
  List<Object?> get props => [category, items];
}

/// Groups [items] by aisle, in the order of [categories]. Items without a
/// known category end up in a last "Others" section; empty aisles are left
/// out. The items keep their order inside a section.
List<AisleSection> groupByAisle(
  List<ShoppingItem> items,
  List<CatalogCategory> categories,
) {
  final byCategory = <String?, List<ShoppingItem>>{};
  final knownIds = {for (final category in categories) category.id};
  for (final item in items) {
    final key = knownIds.contains(item.categoryId) ? item.categoryId : null;
    (byCategory[key] ??= []).add(item);
  }

  return [
    for (final category in categories)
      if (byCategory[category.id] case final aisleItems?)
        AisleSection(category: category, items: aisleItems),
    if (byCategory[null] case final others?)
      AisleSection(category: null, items: others),
  ];
}
