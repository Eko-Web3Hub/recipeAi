import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/fridge/domain/fridge_quantity.dart';
import 'package:recipe_ai/fridge/domain/model/catalog_ingredient.dart';
import 'package:recipe_ai/fridge/domain/model/fridge_item.dart';
import 'package:recipe_ai/fridge/domain/model/fridge_unit.dart';

void main() {
  group('normalizeKey', () {
    test('ignores case, accents, œ and simple plurals', () {
      expect(normalizeKey('Tomates'), normalizeKey('tomate'));
      expect(normalizeKey('Œufs'), 'oeuf');
      expect(normalizeKey('  Épinards   frais '), 'epinard frai');
      expect(normalizeKey('riz'), 'riz');
    });
  });

  group('parseExpress', () {
    test('quantity and unit first', () {
      final entry = parseExpress('500 g tomates');
      expect(entry.amount, 500);
      expect(entry.unit, FridgeUnit.g);
      expect(entry.name, 'tomates');
    });

    test('quantity last', () {
      final entry = parseExpress('tomates 2');
      expect(entry.amount, 2);
      expect(entry.unit, isNull);
      expect(entry.name, 'tomates');
    });

    test('fractions and "de"', () {
      final entry = parseExpress('½ kg de riz');
      expect(entry.amount, 0.5);
      expect(entry.unit, FridgeUnit.kg);
      expect(entry.name, 'riz');
    });

    test('a count without unit', () {
      final entry = parseExpress('3 oignons');
      expect(entry.amount, 3);
      expect(entry.unit, isNull);
      expect(entry.name, 'oignons');
    });

    test('cl is converted to ml', () {
      final entry = parseExpress('2 cl lait');
      expect(entry.amount, 20);
      expect(entry.unit, FridgeUnit.ml);
    });

    test('a word starting like a unit is not a unit', () {
      final entry = parseExpress('2 gousses');
      expect(entry.unit, isNull);
      expect(entry.name, 'gousses');
    });

    test('no quantity: the whole text is the name', () {
      final entry = parseExpress('huile d\'arachide');
      expect(entry.hasAmount, isFalse);
      expect(entry.name, 'huile d\'arachide');
    });
  });

  group('convertAmount', () {
    test('converts within a dimension', () {
      expect(convertAmount(150, FridgeUnit.g, FridgeUnit.kg), 0.15);
      expect(convertAmount(1.5, FridgeUnit.l, FridgeUnit.ml), 1500);
    });

    test('returns null across dimensions', () {
      expect(convertAmount(1, FridgeUnit.kg, FridgeUnit.l), isNull);
      expect(convertAmount(1, FridgeUnit.tas, FridgeUnit.bol), isNull);
    });
  });

  group('mergeAdd', () {
    final existing = FridgeItem.draft(
      name: 'Tomatoes',
      amount: 1,
      unit: FridgeUnit.kg,
    ).copyWith(id: const EntityId('1'));

    test('no quantity: already in', () {
      final (item, outcome) = mergeAdd(
        existing,
        FridgeItem.draft(name: 'Tomatoes'),
      );
      expect(outcome, MergeOutcome.alreadyIn);
      expect(item, existing);
    });

    test('as needed line gets the new quantity', () {
      final (item, outcome) = mergeAdd(
        existing.copyWith(amount: () => null),
        FridgeItem.draft(name: 'Tomatoes', amount: 3, unit: FridgeUnit.piece),
      );
      expect(outcome, MergeOutcome.quantitySet);
      expect(item.amount, 3);
      expect(item.unit, FridgeUnit.piece);
    });

    test('convertible units are added up in the existing unit', () {
      final (item, outcome) = mergeAdd(
        existing,
        FridgeItem.draft(name: 'Tomatoes', amount: 500, unit: FridgeUnit.g),
      );
      expect(outcome, MergeOutcome.total);
      expect(item.amount, 1.5);
      expect(item.unit, FridgeUnit.kg);
      expect(item.id, existing.id);
    });

    test('other units replace the quantity', () {
      final (item, outcome) = mergeAdd(
        existing,
        FridgeItem.draft(name: 'Tomatoes', amount: 2, unit: FridgeUnit.tas),
      );
      expect(outcome, MergeOutcome.replaced);
      expect(item.amount, 2);
      expect(item.unit, FridgeUnit.tas);
    });
  });

  group('parseLegacyQuantity', () {
    test('reads historical free-text quantities', () {
      expect(parseLegacyQuantity('2'), (2.0, FridgeUnit.piece));
      expect(parseLegacyQuantity('500 g'), (500.0, FridgeUnit.g));
      expect(parseLegacyQuantity('1,5 kg'), (1.5, FridgeUnit.kg));
      expect(parseLegacyQuantity('3pcs'), (3.0, FridgeUnit.piece));
    });

    test('falls back on 1 piece', () {
      expect(parseLegacyQuantity(null), (1.0, FridgeUnit.piece));
      expect(parseLegacyQuantity('a handful'), (1.0, FridgeUnit.piece));
    });

    test('reads "as needed"', () {
      expect(parseLegacyQuantity('as needed'), (null, FridgeUnit.piece));
    });
  });

  group('backendQuantityLabel', () {
    test('writes a readable label for the backend', () {
      expect(backendQuantityLabel(1.5, FridgeUnit.kg), '1.5 kg');
      expect(backendQuantityLabel(3, FridgeUnit.piece), '3');
      expect(backendQuantityLabel(2, FridgeUnit.botte), '2 bunch');
      expect(backendQuantityLabel(null, FridgeUnit.g), 'as needed');
    });
  });

  group('resolveDraft', () {
    const okra = CatalogIngredient(
      id: 'okra',
      name: 'Okra',
      nameFr: 'Gombo',
      defaultUnit: FridgeUnit.tas,
      defaultAmount: 1,
    );

    test('uses the catalog defaults without a typed quantity', () {
      final draft = resolveDraft(parseExpress('gombo'), okra);
      expect(draft.name, 'Okra');
      expect(draft.nameFr, 'Gombo');
      expect(draft.amount, 1);
      expect(draft.unit, FridgeUnit.tas);
      expect(draft.catalogId, 'okra');
    });

    test('a typed count keeps the non-measure default unit', () {
      final draft = resolveDraft(parseExpress('3 gombos'), okra);
      expect(draft.amount, 3);
      expect(draft.unit, FridgeUnit.tas);
    });

    test('a free-text entry has no quantity', () {
      final draft = resolveDraft(parseExpress('attiéké'), null);
      expect(draft.name, 'Attiéké');
      expect(draft.amount, isNull);
      expect(draft.catalogId, isNull);
    });
  });
}
