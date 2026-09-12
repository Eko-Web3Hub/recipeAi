import 'package:recipe_ai/user_preferences/domain/model/onboarding_answers.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference.dart';
import 'package:recipe_ai/user_preferences/presentation/onboarding_steps.dart';

/// Keys of the typed fields stored next to the flat `{optionKey: bool}` map.
const genderPreferenceKey = 'gender';
const heightPreferenceKey = 'heightCm';
const weightPreferenceKey = 'weightKg';
const bmiPreferenceKey = 'bmi';
const chronicDiseaseOtherPreferenceKey = 'chronicDiseaseOther';

/// Flattens the answers into the document the recipe backend reads:
/// every option key with its boolean, plus the typed morphology fields.
UserPreference buildUserPreferenceFrom(
  OnboardingAnswers answers, {
  List<OnboardingStep>? steps,
}) {
  final catalogue = steps ?? onboardingSteps;
  final selectedKeys = <String>{
    for (final step in catalogue) ...answers.selectionsOf(step.key),
  };

  return UserPreference({
    for (final step in catalogue)
      for (final option in step.options)
        option.key: selectedKeys.contains(option.key),
    if (answers.gender != null) genderPreferenceKey: answers.gender!.name,
    heightPreferenceKey: answers.heightCm,
    weightPreferenceKey: answers.weightKg,
    bmiPreferenceKey: answers.bmi,
    chronicDiseaseOtherPreferenceKey: answers.chronicDiseaseOther.trim(),
  });
}

/// Rebuilds the answers from a stored document, to pre-fill the quizz when the
/// user edits their preferences from the profile.
OnboardingAnswers answersFrom(
  UserPreference userPreference, {
  List<OnboardingStep>? steps,
}) {
  final catalogue = steps ?? onboardingSteps;
  final preferences = userPreference.preferences;

  return OnboardingAnswers(
    selections: {
      for (final step in catalogue)
        if (step.options.isNotEmpty)
          step.key: {
            for (final option in step.options)
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
    chronicDiseaseOther:
        preferences[chronicDiseaseOtherPreferenceKey] as String? ?? '',
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
