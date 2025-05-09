import 'package:equatable/equatable.dart';
import 'package:recipe_ai/ddd/entity.dart';

class Ingredient extends Equatable {
  final String name;
  final String? nameFr;
  final String? quantity;
  final DateTime? date;
  final EntityId? id;

  const Ingredient({
    required this.name,
    required this.quantity,
    required this.date,
    required this.id,
    this.nameFr,
  });

  Ingredient copy({
    String? name,
    String? nameFr,
    String? quantity,
    DateTime? date,
    EntityId? id,
  }) {
    return Ingredient(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      date: date ?? this.date,
      id: id ?? this.id,
      nameFr: nameFr ?? this.nameFr,
    );
  }

  @override
  List<Object?> get props => [id, name, quantity,nameFr,];
}
