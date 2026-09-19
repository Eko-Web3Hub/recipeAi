import 'package:equatable/equatable.dart';
import 'package:recipe_ai/fridge/domain/fridge_quantity.dart';
import 'package:recipe_ai/fridge/domain/model/fridge_unit.dart';

/// An ingredient of the shared catalog (`Categories/{catId}/ingredients`).
///
/// [defaultUnit], [defaultAmount], [units] and [aliases] are optional in
/// Firestore: when missing, the sheet falls back on [FridgeUnit.related].
class CatalogIngredient extends Equatable {
  const CatalogIngredient({
    required this.id,
    required this.name,
    this.nameFr,
    this.defaultUnit,
    this.defaultAmount,
    this.units = const [],
    this.aliases = const [],
  });

  final String id;
  final String name;
  final String? nameFr;
  final FridgeUnit? defaultUnit;
  final double? defaultAmount;
  final List<FridgeUnit> units;
  final List<String> aliases;

  String displayName(String languageCode) =>
      languageCode == 'fr' && (nameFr?.isNotEmpty ?? false) ? nameFr! : name;

  /// Normalized keys of every name the ingredient can be found with.
  List<String> get searchKeys => [
    normalizeKey(name),
    if (nameFr != null && nameFr!.isNotEmpty) normalizeKey(nameFr!),
    ...aliases.map(normalizeKey),
  ];

  /// Units offered first in the quantity sheet.
  List<FridgeUnit> get suggestedUnits => units.isNotEmpty
      ? units
      : FridgeUnit.related(defaultUnit ?? FridgeUnit.piece);

  @override
  List<Object?> get props => [
    id,
    name,
    nameFr,
    defaultUnit,
    defaultAmount,
    units,
    aliases,
  ];
}
