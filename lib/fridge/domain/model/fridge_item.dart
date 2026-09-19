import 'package:equatable/equatable.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/fridge/domain/fridge_quantity.dart';
import 'package:recipe_ai/fridge/domain/model/fridge_unit.dart';

/// An ingredient in the user's fridge.
///
/// A null [amount] means "as needed": the user has it but did not say how
/// much. [unit] is kept anyway so the sheet reopens on the last unit used.
class FridgeItem extends Equatable {
  const FridgeItem({
    required this.name,
    required this.nameKey,
    required this.amount,
    required this.unit,
    this.id,
    this.nameFr,
    this.catalogId,
    this.date,
  });

  factory FridgeItem.draft({
    required String name,
    String? nameFr,
    double? amount,
    FridgeUnit unit = FridgeUnit.piece,
    String? catalogId,
  }) => FridgeItem(
    name: name,
    nameFr: nameFr,
    nameKey: normalizeKey(name),
    amount: amount,
    unit: unit,
    catalogId: catalogId,
  );

  final EntityId? id;
  final String name;
  final String? nameFr;
  final String nameKey;
  final double? amount;
  final FridgeUnit unit;
  final String? catalogId;
  final DateTime? date;

  bool get isAsNeeded => amount == null;

  String displayName(String languageCode) =>
      languageCode == 'fr' && (nameFr?.isNotEmpty ?? false) ? nameFr! : name;

  /// Every key this item can be matched on, whatever the language it was
  /// typed in.
  Set<String> get matchKeys => {
    nameKey,
    if (nameFr != null && nameFr!.isNotEmpty) normalizeKey(nameFr!),
  };

  bool sameIngredientAs(FridgeItem other) =>
      (catalogId != null && catalogId == other.catalogId) ||
      matchKeys.intersection(other.matchKeys).isNotEmpty;

  FridgeItem copyWith({
    EntityId? id,
    double? Function()? amount,
    FridgeUnit? unit,
    DateTime? date,
  }) => FridgeItem(
    id: id ?? this.id,
    name: name,
    nameFr: nameFr,
    nameKey: nameKey,
    amount: amount != null ? amount() : this.amount,
    unit: unit ?? this.unit,
    catalogId: catalogId,
    date: date ?? this.date,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    nameFr,
    nameKey,
    amount,
    unit,
    catalogId,
  ];
}
