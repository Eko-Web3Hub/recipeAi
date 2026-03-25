import 'package:recipe_ai/shopping/domain/model/inventory_item.dart';
import 'package:recipe_ai/shopping/domain/model/item_category.dart';
import 'package:recipe_ai/shopping/domain/model/item_status.dart';
import 'package:recipe_ai/shopping/domain/model/shopping_item.dart';

const mockCategories = [
  ItemCategory(id: 'all', name: 'Tout'),
  ItemCategory(id: 'fruits_legumes', name: 'Fruits & Legumes', emoji: '\u{1F34E}'),
  ItemCategory(id: 'boulangerie', name: 'Boulangerie', emoji: '\u{1F956}'),
  ItemCategory(id: 'epicerie', name: 'Epicerie', emoji: '\u{1F36C}'),
  ItemCategory(id: 'boissons', name: 'Boissons', emoji: '\u{1F964}'),
  ItemCategory(id: 'frais', name: 'Frais', emoji: '\u{1F9C0}'),
  ItemCategory(id: 'surgeles', name: 'Surgeles', emoji: '\u{2744}'),
];

const mockInventoryItems = [
  InventoryItem(
    id: '1',
    name: 'Avocat',
    emoji: '\u{1F951}',
    quantity: 7,
    unit: 'pieces',
    status: ItemStatus.ok,
    categoryId: 'fruits_legumes',
  ),
  InventoryItem(
    id: '2',
    name: 'Lait concentre',
    emoji: '\u{1F95B}',
    quantity: 2,
    unit: 'pieces',
    status: ItemStatus.lowStock,
    categoryId: 'frais',
  ),
  InventoryItem(
    id: '3',
    name: 'Haricots',
    emoji: '\u{1FAD8}',
    quantity: 0,
    unit: 'pieces',
    status: ItemStatus.outOfStock,
    categoryId: 'fruits_legumes',
  ),
  InventoryItem(
    id: '4',
    name: 'Beurre',
    emoji: '\u{1F9C8}',
    quantity: 2,
    unit: 'plaquettes',
    status: ItemStatus.lowStock,
    categoryId: 'frais',
  ),
  InventoryItem(
    id: '5',
    name: 'Riz basmati',
    emoji: '\u{1F35A}',
    quantity: 3,
    unit: 'paquets',
    status: ItemStatus.ok,
    categoryId: 'epicerie',
  ),
  InventoryItem(
    id: '6',
    name: 'Jus d\'orange',
    emoji: '\u{1F34A}',
    quantity: 1,
    unit: 'bouteilles',
    status: ItemStatus.lowStock,
    categoryId: 'boissons',
  ),
  InventoryItem(
    id: '7',
    name: 'Pain de mie',
    emoji: '\u{1F35E}',
    quantity: 0,
    unit: 'paquets',
    status: ItemStatus.outOfStock,
    categoryId: 'boulangerie',
  ),
  InventoryItem(
    id: '8',
    name: 'Tomates',
    emoji: '\u{1F345}',
    quantity: 5,
    unit: 'pieces',
    status: ItemStatus.ok,
    categoryId: 'fruits_legumes',
  ),
];

const mockShoppingItems = [
  ShoppingItem(
    id: 's1',
    name: 'Avocat',
    emoji: '\u{1F951}',
    quantity: 8,
    unit: 'pieces',
    categoryId: 'fruits_legumes',
  ),
  ShoppingItem(
    id: 's2',
    name: 'Lait concentre',
    emoji: '\u{1F95B}',
    quantity: 7,
    unit: 'pieces',
    categoryId: 'frais',
  ),
  ShoppingItem(
    id: 's3',
    name: 'Haricots',
    emoji: '\u{1FAD8}',
    quantity: 7,
    unit: 'pieces',
    categoryId: 'boulangerie',
    isChecked: true,
  ),
  ShoppingItem(
    id: 's4',
    name: 'Haricots verts',
    emoji: '\u{1FAD8}',
    quantity: 7,
    unit: 'pieces',
    categoryId: 'boulangerie',
    isChecked: true,
  ),
];

const mockSuggestions = [
  ShoppingItem(
    id: 'sg1',
    name: 'Oeufs',
    emoji: '\u{1F95A}',
    quantity: 1,
    unit: 'pieces',
    categoryId: 'frais',
  ),
  ShoppingItem(
    id: 'sg2',
    name: 'Croissant',
    emoji: '\u{1F950}',
    quantity: 1,
    unit: 'pieces',
    categoryId: 'boulangerie',
  ),
  ShoppingItem(
    id: 'sg3',
    name: 'Oignons',
    emoji: '\u{1F9C5}',
    quantity: 1,
    unit: 'pieces',
    categoryId: 'fruits_legumes',
  ),
  ShoppingItem(
    id: 'sg4',
    name: 'Poulet',
    emoji: '\u{1F357}',
    quantity: 1,
    unit: 'pieces',
    categoryId: 'frais',
  ),
];
