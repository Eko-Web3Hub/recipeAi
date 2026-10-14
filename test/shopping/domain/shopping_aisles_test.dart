import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_ai/fridge/domain/model/catalog_category.dart';
import 'package:recipe_ai/fridge/domain/model/fridge_item.dart';
import 'package:recipe_ai/shopping/domain/model/shopping_item.dart';
import 'package:recipe_ai/shopping/domain/shopping_aisles.dart';

void main() {
  const vegetables = CatalogCategory(id: 'veg', name: 'Vegetables');
  const dairy = CatalogCategory(id: 'dairy', name: 'Dairy');
  const bakery = CatalogCategory(id: 'bakery', name: 'Bakery');

  ShoppingItem item(String name, String? categoryId) => ShoppingItem(
    ingredient: FridgeItem.draft(name: name),
    categoryId: categoryId,
  );

  test('groups the items in the order of the categories', () {
    final milk = item('Milk', 'dairy');
    final tomatoes = item('Tomatoes', 'veg');
    final butter = item('Butter', 'dairy');

    final sections = groupByAisle(
      [milk, tomatoes, butter],
      [vegetables, dairy, bakery],
    );

    expect(sections, [
      AisleSection(category: vegetables, items: [tomatoes]),
      AisleSection(category: dairy, items: [milk, butter]),
    ]);
  });

  test('puts custom and unknown categories in a last "Others" section', () {
    final custom = item('Grandma sauce', null);
    final unknown = item('Rice', 'deleted-category');
    final milk = item('Milk', 'dairy');

    final sections = groupByAisle([custom, milk, unknown], [dairy]);

    expect(sections.map((section) => section.category), [dairy, null]);
    expect(sections.last.items, [custom, unknown]);
  });

  test('everything is in "Others" while the categories are not loaded', () {
    final milk = item('Milk', 'dairy');

    expect(groupByAisle([milk], const []), [
      AisleSection(category: null, items: [milk]),
    ]);
  });

  test('no section for an empty list', () {
    expect(groupByAisle(const [], [dairy]), isEmpty);
  });
}
