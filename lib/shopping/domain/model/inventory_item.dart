import 'package:equatable/equatable.dart';
import 'package:recipe_ai/shopping/domain/model/item_status.dart';

class InventoryItem extends Equatable {
  const InventoryItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.quantity,
    required this.unit,
    required this.status,
    required this.categoryId,
  });

  final String id;
  final String name;
  final String emoji;
  final int quantity;
  final String unit;
  final ItemStatus status;
  final String categoryId;

  InventoryItem copyWith({
    String? id,
    String? name,
    String? emoji,
    int? quantity,
    String? unit,
    ItemStatus? status,
    String? categoryId,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      status: status ?? this.status,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  @override
  List<Object?> get props => [id, name, emoji, quantity, unit, status, categoryId];
}
