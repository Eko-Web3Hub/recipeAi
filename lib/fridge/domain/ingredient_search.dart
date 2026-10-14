import 'package:equatable/equatable.dart';
import 'package:recipe_ai/fridge/domain/fridge_quantity.dart';
import 'package:recipe_ai/fridge/domain/model/catalog_ingredient.dart';
import 'package:recipe_ai/fridge/domain/model/fridge_item.dart';
import 'package:recipe_ai/fridge/domain/model/fridge_unit.dart';

/// Offered while the user has no history of added ingredients.
final defaultFridgeUsuals = [
  FridgeItem.draft(name: 'Milk', nameFr: 'Lait', amount: 1, unit: FridgeUnit.l),
  FridgeItem.draft(
    name: 'Eggs',
    nameFr: 'Œufs',
    amount: 6,
    unit: FridgeUnit.piece,
  ),
  FridgeItem.draft(
    name: 'Chicken',
    nameFr: 'Poulet',
    amount: 1,
    unit: FridgeUnit.kg,
  ),
  FridgeItem.draft(
    name: 'Chili pepper',
    nameFr: 'Piment',
    amount: 5,
    unit: FridgeUnit.piece,
  ),
  FridgeItem.draft(
    name: 'Okra',
    nameFr: 'Gombo',
    amount: 1,
    unit: FridgeUnit.tas,
  ),
  FridgeItem.draft(
    name: 'Peanut oil',
    nameFr: "Huile d'arachide",
    amount: 1,
    unit: FridgeUnit.l,
  ),
];

class IngredientSuggestion extends Equatable {
  const IngredientSuggestion({
    required this.draft,
    required this.isCustom,
    required this.isAlreadyAdded,
  });

  final FridgeItem draft;

  /// "Add « xxx »": no catalog ingredient matches the typed name.
  final bool isCustom;

  /// The ingredient is already in the fridge / the list being edited.
  final bool isAlreadyAdded;

  @override
  List<Object?> get props => [draft, isCustom, isAlreadyAdded];
}

/// Result of [IngredientSearch.search]. [hasAmount] is true when the query
/// holds a quantity ("500 g tomates"): Enter adds it directly.
typedef IngredientQueryResult = ({
  List<IngredientSuggestion> suggestions,
  bool hasAmount,
});

/// Searches the shared ingredient catalog, for the fridge and the shopping
/// lists alike.
class IngredientSearch {
  const IngredientSearch([this.catalog = const []]);

  static const maxSuggestions = 4;

  final List<CatalogIngredient> catalog;

  /// The catalog ingredient [item] was picked from, or the one sharing one
  /// of its names.
  CatalogIngredient? catalogFor(FridgeItem item) {
    for (final ingredient in catalog) {
      if (item.catalogId != null && ingredient.id == item.catalogId) {
        return ingredient;
      }
    }
    for (final ingredient in catalog) {
      if (ingredient.searchKeys.any(item.matchKeys.contains)) {
        return ingredient;
      }
    }
    return null;
  }

  CatalogIngredient? _exactMatch(String key) {
    for (final ingredient in catalog) {
      if (ingredient.searchKeys.contains(key)) return ingredient;
    }
    return null;
  }

  /// Units offered first in the quantity sheet of [item], starting with its
  /// current unit.
  List<FridgeUnit> unitsFor(FridgeItem item) {
    final units =
        catalogFor(item)?.suggestedUnits ?? FridgeUnit.related(item.unit);
    return [item.unit, ...units.where((unit) => unit != item.unit)];
  }

  /// A usual chip turned into a draft, completed with the catalog when the
  /// ingredient is found in it.
  FridgeItem draftForUsual(FridgeItem usual) {
    final ingredient = catalogFor(usual);
    if (ingredient == null) return usual;
    return FridgeItem.draft(
      name: ingredient.name,
      nameFr: ingredient.nameFr ?? usual.nameFr,
      amount: usual.amount,
      unit: usual.unit,
      catalogId: ingredient.id,
    );
  }

  /// Suggestions for [query]: exact match first, then the names starting
  /// with it, then the names with a word starting with it, plus "Add « xxx »"
  /// when nothing matches exactly.
  IngredientQueryResult search(
    String query, {
    required bool Function(FridgeItem draft) isAlreadyAdded,
  }) {
    final parsed = parseExpress(query);
    final key = normalizeKey(parsed.name);
    if (key.isEmpty) return (suggestions: const [], hasAmount: false);

    final exact = _exactMatch(key);
    final startsWith = <CatalogIngredient>[];
    final wordStartsWith = <CatalogIngredient>[];
    for (final ingredient in catalog) {
      if (ingredient == exact) continue;
      final keys = ingredient.searchKeys;
      if (keys.any((name) => name.startsWith(key))) {
        startsWith.add(ingredient);
      } else if (keys.any(
        (name) => name.split(' ').any((word) => word.startsWith(key)),
      )) {
        wordStartsWith.add(ingredient);
      }
    }

    final matches = [
      if (exact != null) exact,
      ...startsWith,
      ...wordStartsWith,
    ].take(maxSuggestions);

    IngredientSuggestion suggestion(FridgeItem draft, {required bool custom}) =>
        IngredientSuggestion(
          draft: draft,
          isCustom: custom,
          isAlreadyAdded: isAlreadyAdded(draft),
        );

    return (
      suggestions: [
        for (final ingredient in matches)
          suggestion(resolveDraft(parsed, ingredient), custom: false),
        if (exact == null && parsed.name.trim().length > 1)
          suggestion(resolveDraft(parsed, null), custom: true),
      ],
      hasAmount: parsed.hasAmount,
    );
  }
}
