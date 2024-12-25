import 'package:equatable/equatable.dart';

class Ingredient extends Equatable {
  final String name;
  final String? quantity;
  final DateTime? date;

  const Ingredient(
      {required this.name, required this.quantity, required this.date});

  Ingredient copy({
    String? name,
    String? quantity,
    DateTime? date,
  }) {
    return Ingredient(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      date: date ?? this.date,
    );
  }

  @override
  List<Object?> get props => [name, quantity];
}
