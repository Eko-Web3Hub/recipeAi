import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/fridge/domain/fridge_quantity.dart';
import 'package:recipe_ai/fridge/domain/model/fridge_item.dart';
import 'package:recipe_ai/fridge/domain/model/fridge_unit.dart';

/// Document of `KitchenInventory/{uid}/ingredients/{id}`.
///
/// `id`, `name`, `nameFr`, `quantity` and `date` are the historical fields,
/// still read by the recipe generation backend: `quantity` is always written
/// as a readable label. `amount`, `unit`, `nameKey`, `catalogId` and
/// `updatedAt` were added for the "Mon frigo" tab. Documents written before
/// have no `amount` / `unit`: they are parsed from `quantity`.
abstract class FridgeItemSerialization {
  static FridgeItem fromJson(Map<String, dynamic> json, {String? docId}) {
    final name = json['name'] as String? ?? '';
    final FridgeUnit unit;
    final double? amount;
    final storedUnit = FridgeUnit.fromKey(json['unit'] as String?);
    if (storedUnit != null) {
      unit = storedUnit;
      amount = (json['amount'] as num?)?.toDouble();
    } else {
      (amount, unit) = parseLegacyQuantity(json['quantity']?.toString());
    }
    final id = json['id'] as String? ?? docId;

    return FridgeItem(
      id: id == null ? null : EntityId(id),
      name: name,
      nameFr: json['nameFr'] as String?,
      nameKey: json['nameKey'] as String? ?? normalizeKey(name),
      amount: amount,
      unit: unit,
      catalogId: json['catalogId'] as String?,
      date: (json['date'] as Timestamp?)?.toDate(),
    );
  }

  static Map<String, dynamic> toJson(FridgeItem item) => {
    'id': item.id?.value,
    'name': item.name,
    'nameFr': item.nameFr,
    'nameKey': item.nameKey,
    'quantity': backendQuantityLabel(item.amount, item.unit),
    'amount': item.amount,
    'unit': item.unit.key,
    'catalogId': item.catalogId,
    'date': item.date ?? DateTime.now(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  /// Document of `KitchenInventory/{uid}/usuals/{nameKey}`, merged on every
  /// add so [count] ranks the user's usual ingredients.
  static Map<String, dynamic> usualToJson(FridgeItem item) => {
    'name': item.name,
    'nameFr': item.nameFr,
    'nameKey': item.nameKey,
    'catalogId': item.catalogId,
    'amount': item.amount,
    'unit': item.unit.key,
    'count': FieldValue.increment(1),
    'lastAddedAt': FieldValue.serverTimestamp(),
  };

  static FridgeItem usualFromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? '';
    return FridgeItem(
      name: name,
      nameFr: json['nameFr'] as String?,
      nameKey: json['nameKey'] as String? ?? normalizeKey(name),
      amount: (json['amount'] as num?)?.toDouble(),
      unit: FridgeUnit.fromKey(json['unit'] as String?) ?? FridgeUnit.piece,
      catalogId: json['catalogId'] as String?,
    );
  }
}
