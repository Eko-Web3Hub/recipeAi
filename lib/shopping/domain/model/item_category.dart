import 'package:equatable/equatable.dart';

class ItemCategory extends Equatable {
  const ItemCategory({
    required this.id,
    required this.name,
    this.emoji,
  });

  final String id;
  final String name;
  final String? emoji;

  @override
  List<Object?> get props => [id, name, emoji];
}
