import 'package:equatable/equatable.dart';

class ShoppingItem extends Equatable {
  const ShoppingItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.quantity,
    required this.unit,
    required this.categoryId,
    this.isChecked = false,
  });

  final String id;
  final String name;
  final String emoji;
  final int quantity;
  final String unit;
  final String categoryId;
  final bool isChecked;

  ShoppingItem copyWith({
    String? id,
    String? name,
    String? emoji,
    int? quantity,
    String? unit,
    String? categoryId,
    bool? isChecked,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      categoryId: categoryId ?? this.categoryId,
      isChecked: isChecked ?? this.isChecked,
    );
  }

  @override
  List<Object?> get props => [id, name, emoji, quantity, unit, categoryId, isChecked];
}
