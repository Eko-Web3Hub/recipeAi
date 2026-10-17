import 'package:equatable/equatable.dart';

enum RecipeSourceType { link, author, other }

RecipeSourceType recipeSourceTypeFromString(String value) {
  return RecipeSourceType.values.firstWhere(
    (type) => type.name == value,
    orElse: () => RecipeSourceType.other,
  );
}

/// Where a recipe comes from (e.g. a website it was adapted from, the
/// person who shared it), shown as a card on the recipe details screen.
class RecipeSource extends Equatable {
  const RecipeSource({required this.type, required this.value});

  final RecipeSourceType type;
  final String value;

  @override
  List<Object?> get props => [type, value];
}
