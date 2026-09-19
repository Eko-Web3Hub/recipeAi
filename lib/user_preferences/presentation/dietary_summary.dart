import 'package:recipe_ai/user_preferences/domain/model/onboarding_step.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference.dart';
import 'package:recipe_ai/utils/constant.dart';

/// Steps whose answers describe the user's diet on the home screen
/// ("Adaptées à tes préférences · Végétarien, Diabète").
const dietarySummaryStepKeys = ['diet_profile', 'chronic_disease'];

/// Labels of the diet and chronic disease options the user picked, in the
/// catalogue order, without the "none" options.
List<String> dietarySummaryLabels(
  UserPreference userPreference,
  List<OnboardingStep> steps,
  AppLanguage language,
) {
  final preferences = userPreference.preferences;

  return [
    for (final stepKey in dietarySummaryStepKeys)
      for (final step in steps.where((step) => step.key == stepKey))
        for (final option in step.allOptions)
          if (option.key != step.exclusiveOptionKey &&
              preferences[option.key] == true)
            option.label.resolve(language),
  ];
}
