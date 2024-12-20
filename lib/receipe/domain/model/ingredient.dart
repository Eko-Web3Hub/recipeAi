import 'package:equatable/equatable.dart';

class Ingredient extends Equatable {
  final String name;
  final String? quantity;

  const Ingredient({
    required this.name,
    required this.quantity,
  });

  @override
  List<Object?> get props => [name, quantity];
}
