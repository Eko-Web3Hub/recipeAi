import 'package:flutter/material.dart';
import 'package:recipe_ai/l10n/app_localizations.dart';
import 'package:recipe_ai/utils/colors.dart';

/// Catalogue of the onboarding quizz. The steps are defined here rather than
/// loaded from Firestore: their layout (dot colors, icons, single vs multiple
/// choice, the morphology form) is too specific to be driven by data.
///
/// Adding a step is adding an entry to [onboardingSteps]: the progress bar and
/// the pagination follow.

typedef LocalizedText = String Function(AppLocalizations lang);

enum OnboardingStepKind {
  /// A list of options to pick from.
  options,

  /// The gender / height / weight form with the BMI card.
  morphology,
}

enum OptionSelectionMode { single, multiple }

enum OptionTileStyle {
  /// 36px colored dot, round checkbox (step "profil alimentaire").
  colorDot,

  /// 40px rounded icon tile (steps "activité" and "objectifs").
  iconTile,

  /// 8px colored dot, square checkbox (step "maladies chroniques").
  smallDot,
}

class OnboardingOption {
  const OnboardingOption({
    required this.key,
    required this.label,
    this.description,
    this.color,
    this.icon,
  });

  /// Stable, language independent key written to Firestore.
  final String key;
  final LocalizedText label;
  final LocalizedText? description;
  final Color? color;
  final IconData? icon;
}

class OnboardingStep {
  const OnboardingStep({
    required this.key,
    required this.title,
    required this.helper,
    this.kind = OnboardingStepKind.options,
    this.selectionMode = OptionSelectionMode.multiple,
    this.tileStyle = OptionTileStyle.colorDot,
    this.options = const [],
    this.exclusiveOptionKey,
    this.hasOtherField = false,
    this.footnote,
  });

  final String key;
  final LocalizedText title;
  final LocalizedText helper;
  final OnboardingStepKind kind;
  final OptionSelectionMode selectionMode;
  final OptionTileStyle tileStyle;
  final List<OnboardingOption> options;

  /// Option that clears every other one when picked, and is cleared by them
  /// ("Aucune restriction").
  final String? exclusiveOptionKey;

  /// Free text field under the options ("Autre").
  final bool hasOtherField;
  final LocalizedText? footnote;
}

const dietStepKey = 'diet_profile';
const activityStepKey = 'activity_level';
const goalsStepKey = 'goals';
const chronicDiseaseStepKey = 'chronic_disease';

final onboardingSteps = <OnboardingStep>[
  OnboardingStep(
    key: dietStepKey,
    title: (lang) => lang.onboardingDietTitle,
    helper: (lang) => lang.onboardingDietHelper,
    exclusiveOptionKey: 'no_restriction',
    options: [
      OnboardingOption(
        key: 'no_restriction',
        label: (lang) => lang.dietNoRestriction,
        color: recipeLoaderGreenColor,
      ),
      OnboardingOption(
        key: 'vegetarian',
        label: (lang) => lang.dietVegetarian,
        color: optionOliveColor,
      ),
      OnboardingOption(
        key: 'gluten_free',
        label: (lang) => lang.dietGlutenFree,
        color: optionTerraColor,
      ),
      OnboardingOption(
        key: 'lactose_free',
        label: (lang) => lang.dietLactoseFree,
        color: optionAmberColor,
      ),
      OnboardingOption(
        key: 'vegan',
        label: (lang) => lang.dietVegan,
        color: optionBrownColor,
      ),
    ],
  ),
  OnboardingStep(
    key: 'morphology',
    kind: OnboardingStepKind.morphology,
    title: (lang) => lang.onboardingMorphologyTitle,
    helper: (lang) => lang.onboardingMorphologyHelper,
  ),
  OnboardingStep(
    key: activityStepKey,
    title: (lang) => lang.onboardingActivityTitle,
    helper: (lang) => lang.onboardingActivityHelper,
    selectionMode: OptionSelectionMode.single,
    tileStyle: OptionTileStyle.iconTile,
    options: [
      OnboardingOption(
        key: 'sedentary',
        label: (lang) => lang.activitySedentary,
        description: (lang) => lang.activitySedentaryDescription,
        icon: Icons.chair_outlined,
      ),
      OnboardingOption(
        key: 'lightly_active',
        label: (lang) => lang.activityLightlyActive,
        description: (lang) => lang.activityLightlyActiveDescription,
        icon: Icons.directions_walk,
      ),
      OnboardingOption(
        key: 'moderately_active',
        label: (lang) => lang.activityModeratelyActive,
        description: (lang) => lang.activityModeratelyActiveDescription,
        icon: Icons.directions_bike,
      ),
      OnboardingOption(
        key: 'very_active',
        label: (lang) => lang.activityVeryActive,
        description: (lang) => lang.activityVeryActiveDescription,
        icon: Icons.directions_run,
      ),
      OnboardingOption(
        key: 'athlete',
        label: (lang) => lang.activityAthlete,
        description: (lang) => lang.activityAthleteDescription,
        icon: Icons.local_fire_department_outlined,
      ),
    ],
  ),
  OnboardingStep(
    key: goalsStepKey,
    title: (lang) => lang.onboardingGoalsTitle,
    helper: (lang) => lang.onboardingGoalsHelper,
    tileStyle: OptionTileStyle.iconTile,
    options: [
      OnboardingOption(
        key: 'weight_loss',
        label: (lang) => lang.goalWeightLoss,
        description: (lang) => lang.goalWeightLossDescription,
        icon: Icons.trending_up,
      ),
      OnboardingOption(
        key: 'health_improvement',
        label: (lang) => lang.goalHealthImprovement,
        description: (lang) => lang.goalHealthImprovementDescription,
        icon: Icons.favorite_border,
      ),
      OnboardingOption(
        key: 'muscle_gain',
        label: (lang) => lang.goalMuscleGain,
        description: (lang) => lang.goalMuscleGainDescription,
        icon: Icons.fitness_center,
      ),
      OnboardingOption(
        key: 'detox',
        label: (lang) => lang.goalDetox,
        description: (lang) => lang.goalDetoxDescription,
        icon: Icons.water_drop_outlined,
      ),
    ],
  ),
  OnboardingStep(
    key: chronicDiseaseStepKey,
    title: (lang) => lang.onboardingChronicDiseaseTitle,
    helper: (lang) => lang.onboardingChronicDiseaseHelper,
    tileStyle: OptionTileStyle.smallDot,
    hasOtherField: true,
    footnote: (lang) => lang.onboardingChronicDiseaseFootnote,
    options: [
      OnboardingOption(
        key: 'diabetes',
        label: (lang) => lang.chronicDiabetes,
        color: optionAmberColor,
      ),
      OnboardingOption(
        key: 'cardiovascular_disease',
        label: (lang) => lang.chronicCardiovascular,
        color: optionTerraColor,
      ),
      OnboardingOption(
        key: 'overweight',
        label: (lang) => lang.chronicOverweight,
        color: optionOliveColor,
      ),
      OnboardingOption(
        key: 'hypertension',
        label: (lang) => lang.chronicHypertension,
        color: optionBrownColor,
      ),
      OnboardingOption(
        key: 'smop',
        label: (lang) => lang.chronicSmop,
        color: optionBlueColor,
      ),
    ],
  ),
];

/// Every option key of the quizz, used to write the flat `{key: bool}` map the
/// recipe backend reads.
List<String> get allOnboardingOptionKeys => [
  for (final step in onboardingSteps)
    for (final option in step.options) option.key,
];
