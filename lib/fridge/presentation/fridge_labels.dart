import 'package:recipe_ai/fridge/domain/fridge_quantity.dart';
import 'package:recipe_ai/fridge/domain/model/fridge_unit.dart';
import 'package:recipe_ai/l10n/app_localizations.dart';

extension FridgeLabels on AppLocalizations {
  bool get _isFrench => localeName.startsWith('fr');

  String fridgeAmount(double amount) =>
      formatAmount(amount, decimalSeparator: _isFrench ? ',' : '.');

  /// Unit word agreeing with [amount] ("pièces", "bunch", "kg").
  String fridgeUnitWord(FridgeUnit unit, [double amount = 1]) => switch (unit) {
    FridgeUnit.piece => fridgeUnitPiece(amount),
    FridgeUnit.g => 'g',
    FridgeUnit.kg => 'kg',
    FridgeUnit.ml => 'ml',
    FridgeUnit.l => 'L',
    FridgeUnit.bol => fridgeUnitBowl(amount),
    FridgeUnit.tas => fridgeUnitHeap(amount),
    FridgeUnit.botte => fridgeUnitBunch(amount),
    FridgeUnit.sachet => fridgeUnitBag(amount),
    FridgeUnit.boite => fridgeUnitCan(amount),
    FridgeUnit.cas => fridgeUnitTablespoon,
  };

  /// Quantity pill of a fridge row: "1 kg", "3" for pieces, "as needed".
  String fridgeQuantityLabel(double? amount, FridgeUnit unit) {
    if (amount == null) return fridgeAsNeeded;
    if (unit == FridgeUnit.piece) return fridgeAmount(amount);
    return '${fridgeAmount(amount)} ${fridgeUnitWord(unit, amount)}';
  }
}
