import 'package:equatable/equatable.dart';
import 'package:recipe_ai/ddd/entity.dart';

class Category extends Equatable {
  final EntityId? id;
  final String name;
  final String nameFr;

  const Category({required this.id, required this.name, required this.nameFr,});

  Category copy({
    EntityId? id,
    String? name,
    String? nameFr,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      nameFr: nameFr ?? this.nameFr,
    );
  }

  @override
  List<Object?> get props => [id, name,nameFr,];
}
