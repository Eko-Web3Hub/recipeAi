import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_ai/user_preferences/domain/model/onboarding_step.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference.dart';
import 'package:recipe_ai/user_preferences/presentation/dietary_summary.dart';
import 'package:recipe_ai/utils/constant.dart';

OnboardingOption _option(String key, String fr, String en) => OnboardingOption(
  key: key,
  label: LocalizedString({'fr': fr, 'en': en}),
);

OnboardingStep _step(
  String key,
  List<OnboardingOption> options, {
  String? exclusiveOptionKey,
}) => OnboardingStep(
  key: key,
  title: const LocalizedString({'fr': '', 'en': ''}),
  helper: const LocalizedString({'fr': '', 'en': ''}),
  options: options,
  exclusiveOptionKey: exclusiveOptionKey,
);

void main() {
  final steps = [
    _step('diet_profile', [
      _option('no_restriction', 'Aucune restriction', 'No restriction'),
      _option('vegetarian', 'Végétarien', 'Vegetarian'),
    ], exclusiveOptionKey: 'no_restriction'),
    _step('goals', [_option('weight_loss', 'Perte de poids', 'Weight loss')]),
    _step('chronic_disease', [
      _option('no_chronic_disease', 'Aucune', 'None'),
      _option('diabetes', 'Diabète', 'Diabetes'),
      _option('smop', 'SMOP (ex SOPK)', 'PCOS'),
    ], exclusiveOptionKey: 'no_chronic_disease'),
  ];

  test('lists the picked diets then chronic diseases, translated', () {
    const preferences = UserPreference({
      'vegetarian': true,
      'weight_loss': true,
      'diabetes': true,
      'smop': true,
    });

    expect(dietarySummaryLabels(preferences, steps, AppLanguage.fr), [
      'Végétarien',
      'Diabète',
      'SMOP (ex SOPK)',
    ]);
    expect(dietarySummaryLabels(preferences, steps, AppLanguage.en), [
      'Vegetarian',
      'Diabetes',
      'PCOS',
    ]);
  });

  test('ignores the "none" options and unpicked ones', () {
    const preferences = UserPreference({
      'no_restriction': true,
      'no_chronic_disease': true,
      'vegetarian': false,
    });

    expect(dietarySummaryLabels(preferences, steps, AppLanguage.fr), isEmpty);
  });
}
