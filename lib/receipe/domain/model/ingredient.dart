import 'package:equatable/equatable.dart';

class Ingredient extends Equatable {
  final String name;
  final String? quantity;
  final DateTime? date;

  const Ingredient({
    required this.name,
    required this.quantity,
    required this.date
  });

  @override
  List<Object?> get props => [name, quantity];
}
