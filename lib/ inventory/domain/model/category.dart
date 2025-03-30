import 'package:equatable/equatable.dart';
import 'package:recipe_ai/ddd/entity.dart';

class Category extends Equatable {
  final EntityId? id;
  final String name;

  const Category({required this.id, required this.name});

  Category copy({
    EntityId? id,
    String? name,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
  
  @override
  List<Object?> get props => [id,name];
}