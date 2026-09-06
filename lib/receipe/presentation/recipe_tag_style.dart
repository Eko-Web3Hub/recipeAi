/// Dietary tags come from the generation backend as free text ("Végé",
/// "Diabétique", "Sans gluten", ...). They are grouped into three families so
/// every screen colors the same tag the same way, each with its own palette:
/// light chips on the recipe details screen, bright text on the recipe cards.
enum RecipeTagKind {
  /// Vegetarian, SOPK, and anything without a more specific family.
  green,

  /// Medical / restrictive diets: diabetic, gluten free, ...
  amber,

  /// Vegan.
  salmon,
}

RecipeTagKind classifyRecipeTag(String label) {
  final normalized = label.toLowerCase();

  if (normalized.contains('végétalien') ||
      normalized.contains('vegetalien') ||
      normalized.contains('vegan')) {
    return RecipeTagKind.salmon;
  }

  if (normalized.contains('diab') ||
      normalized.contains('diet') ||
      normalized.contains('gluten')) {
    return RecipeTagKind.amber;
  }

  return RecipeTagKind.green;
}
