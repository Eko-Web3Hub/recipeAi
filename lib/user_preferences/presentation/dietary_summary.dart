import 'package:recipe_ai/user_preferences/domain/model/onboarding_step.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference.dart';
import 'package:recipe_ai/utils/constant.dart';

const dietProfileStepKey = 'diet_profile';

/// The "Un point d'attention pour tes repas ?" step. It kept the key (and the
/// option keys) of the former chronic disease step, read by the backend.
const chronicDiseaseStepKey = 'chronic_disease';

/// Steps whose answers describe the user's diet on the home screen
/// ("Adaptées à tes préférences · Végétarien, Limiter le sel") and the profile
/// badges.
const dietarySummaryStepKeys = [dietProfileStepKey, chronicDiseaseStepKey];

/// A picked diet or chronic disease option, with the step it answers so the
/// profile can color diets and diseases differently.
typedef DietarySummaryEntry = ({String stepKey, String label});

/// The diet and chronic disease options the user picked, in the catalogue
/// order, without the "none" options.
List<DietarySummaryEntry> dietarySummaryEntries(
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
            (stepKey: stepKey, label: option.label.resolve(language)),
  ];
}

/// Labels of [dietarySummaryEntries].
List<String> dietarySummaryLabels(
  UserPreference userPreference,
  List<OnboardingStep> steps,
  AppLanguage language,
) => [
  for (final entry in dietarySummaryEntries(userPreference, steps, language))
    entry.label,
];
