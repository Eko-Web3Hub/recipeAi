import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_ai/user_preferences/domain/model/onboarding_answers.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference.dart';
import 'package:recipe_ai/user_preferences/presentation/onboarding_preference_mapper.dart';

void main() {
  group('bmiOf', () {
    test('computes the BMI from the stored height and weight', () {
      const preferences = UserPreference({'heightCm': 170, 'weightKg': 68});

      expect(bmiOf(preferences), 23.5);
    });

    test('reads numbers written as doubles', () {
      const preferences = UserPreference({
        'heightCm': 170.0,
        'weightKg': 68.0,
      });

      expect(bmiOf(preferences), 23.5);
    });

    test('falls back on the stored bmi when the morphology is missing', () {
      const preferences = UserPreference({'bmi': 26.4});

      expect(bmiOf(preferences), 26.4);
    });

    test('is null for a document written before the morphology step', () {
      const preferences = UserPreference({'vegetarian': true});

      expect(bmiOf(preferences), isNull);
    });

    test('is null rather than infinite when the height is zero', () {
      const preferences = UserPreference({'heightCm': 0, 'weightKg': 68});

      expect(bmiOf(preferences), isNull);
    });
  });

  group('bmiCategoryOf', () {
    test('splits on the WHO thresholds', () {
      expect(bmiCategoryOf(18.4), BmiCategory.underweight);
      expect(bmiCategoryOf(18.5), BmiCategory.normal);
      expect(bmiCategoryOf(24.9), BmiCategory.normal);
      expect(bmiCategoryOf(25), BmiCategory.overweight);
      expect(bmiCategoryOf(29.9), BmiCategory.overweight);
      expect(bmiCategoryOf(30), BmiCategory.obesity);
    });
  });
}
