import 'package:recipe_ai/user_preferences/domain/model/onboarding_answers.dart';
import 'package:recipe_ai/user_preferences/domain/model/onboarding_step.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference.dart';

/// Keys of the typed fields stored next to the flat `{optionKey: bool}` map.
/// The free texts are stored under their `OnboardingOtherField.preferenceKey`.
const genderPreferenceKey = 'gender';
const heightPreferenceKey = 'heightCm';
const weightPreferenceKey = 'weightKg';
const bmiPreferenceKey = 'bmi';

/// Every option key of the catalogue, used to write the flat `{key: bool}` map
/// the recipe backend reads.
List<String> allOptionKeysOf(List<OnboardingStep> steps) => [
  for (final step in steps)
    for (final option in step.allOptions) option.key,
];

/// Flattens the answers into the document the recipe backend reads:
/// every option key with its boolean, the free texts, plus the typed
/// morphology fields.
UserPreference buildUserPreferenceFrom(
  OnboardingAnswers answers, {
  required List<OnboardingStep> steps,
}) {
  final selectedKeys = <String>{
    for (final step in steps) ...answers.selectionsOf(step.key),
  };

  return UserPreference({
    for (final key in allOptionKeysOf(steps)) key: selectedKeys.contains(key),
    for (final step in steps)
      if (step.otherField case final field?)
        field.preferenceKey: answers.textOf(field.preferenceKey).trim(),
    if (answers.gender != null) genderPreferenceKey: answers.gender!.name,
    heightPreferenceKey: answers.heightCm,
    weightPreferenceKey: answers.weightKg,
    bmiPreferenceKey: answers.bmi,
  });
}

/// Rebuilds the answers from a stored document, to pre-fill the quizz when the
/// user edits their preferences from the profile.
OnboardingAnswers answersFrom(
  UserPreference userPreference, {
  required List<OnboardingStep> steps,
}) {
  final preferences = userPreference.preferences;

  return OnboardingAnswers(
    selections: {
      for (final step in steps)
        if (step.allOptions.isNotEmpty)
          step.key: {
            for (final option in step.allOptions)
              if (preferences[option.key] == true) option.key,
          },
    },
    gender: _genderFrom(preferences[genderPreferenceKey]),
    heightCm:
        _intFrom(preferences[heightPreferenceKey]) ??
        OnboardingAnswers.defaultHeightCm,
    weightKg:
        _intFrom(preferences[weightPreferenceKey]) ??
        OnboardingAnswers.defaultWeightKg,
    texts: {
      for (final step in steps)
        if (step.otherField case final field?)
          if (preferences[field.preferenceKey] case final String text)
            field.preferenceKey: text,
    },
  );
}

UserGender? _genderFrom(dynamic value) {
  if (value is! String) return null;
  for (final gender in UserGender.values) {
    if (gender.name == value) return gender;
  }
  return null;
}

int? _intFrom(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.round();
  if (value is String) return int.tryParse(value);
  return null;
}
