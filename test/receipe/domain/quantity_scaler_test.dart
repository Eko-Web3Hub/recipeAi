import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_ai/receipe/domain/model/quantity_scaler.dart';

void main() {
  group('scaleQuantity', () {
    test('keeps every quantity as written for the base portions', () {
      for (final quantity in ['300g', '1 1/2 cups', '½ lemon', 'a handful']) {
        expect(scaleQuantity(quantity, 1), quantity);
      }
    });

    test('scales the risotto of the screenshot from 2 to 4 portions', () {
      const expected = {
        '300g': '600g',
        '1 litre': '2 litre',
        '250g': '500g',
        '1 medium': '2 medium',
        '2 cloves': '4 cloves',
        '2 tablespoons': '4 tablespoons',
        '100ml': '200ml',
      };
      expected.forEach((quantity, scaled) {
        expect(scaleQuantity(quantity, 2), scaled, reason: quantity);
      });
    });

    test('leaves quantities without an amount untouched', () {
      expect(scaleQuantity('a handful', 3), 'a handful');
      expect(scaleQuantity('to taste', 3), 'to taste');
      expect(scaleQuantity('une pincée', 3), 'une pincée');
    });

    test('keeps the unit and its spacing', () {
      expect(scaleQuantity('300 g', 1.5), '450 g');
      expect(scaleQuantity('about 200g', 1.5), 'about 300g');
    });

    test('rounds 10 and more to the unit, below to one decimal', () {
      expect(scaleQuantity('250g', 1.5), '375g');
      expect(scaleQuantity('75g', 0.5), '38g');
      expect(scaleQuantity('1 medium', 1.5), '1.5 medium');
      expect(scaleQuantity('1 medium', 0.5), '0.5 medium');
    });

    test('writes decimals with the language separator', () {
      expect(
        scaleQuantity('1 oignon', 1.5, decimalSeparator: ','),
        '1,5 oignon',
      );
    });

    test('keeps a comma the quantity already used', () {
      expect(scaleQuantity('1,5 L', 2), '3 L');
      expect(scaleQuantity('1,5 L', 0.5), '0,8 L');
    });

    test('reads fractions, mixed numbers and vulgar fractions', () {
      expect(scaleQuantity('1/2 lemon', 2), '1 lemon');
      expect(scaleQuantity('1 1/2 cups', 2), '3 cups');
      expect(scaleQuantity('½ citron', 3), '1.5 citron');
      expect(scaleQuantity('1½ cups', 2), '3 cups');
    });

    test('scales both ends of a range', () {
      expect(scaleQuantity('2-3 cloves', 2), '4-6 cloves');
      expect(
        scaleQuantity('2 à 3 gousses', 1.5, decimalSeparator: ','),
        '3 à 4,5 gousses',
      );
    });

    test('does not mistake a word starting with "to" for a range', () {
      expect(scaleQuantity('2 tomatoes', 2), '4 tomatoes');
    });

    test('never scales an amount down to zero', () {
      expect(scaleQuantity('⅛ tsp', 0.25), '0.1 tsp');
    });
  });
}
