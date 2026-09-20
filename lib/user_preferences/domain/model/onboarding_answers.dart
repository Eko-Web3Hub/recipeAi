import 'package:equatable/equatable.dart';

enum UserGender { female, male, other }

enum BmiCategory { underweight, normal, overweight, obesity }

/// Where a body mass index sits on the WHO scale.
BmiCategory bmiCategoryOf(double bmi) {
  if (bmi < 18.5) return BmiCategory.underweight;
  if (bmi < 25) return BmiCategory.normal;
  if (bmi < 30) return BmiCategory.overweight;
  return BmiCategory.obesity;
}

/// Answers collected during the onboarding quizz, before they are flattened
/// into a [UserPreference] document.
class OnboardingAnswers extends Equatable {
  const OnboardingAnswers({
    this.selections = const {},
    this.gender,
    this.heightCm = defaultHeightCm,
    this.weightKg = defaultWeightKg,
    this.texts = const {},
  });

  static const defaultHeightCm = 170;
  static const defaultWeightKg = 68;

  static const minHeightCm = 100;
  static const maxHeightCm = 250;
  static const minWeightKg = 30;
  static const maxWeightKg = 300;

  /// Selected option keys, per step key.
  final Map<String, Set<String>> selections;
  final UserGender? gender;
  final int heightCm;
  final int weightKg;

  /// Free text fields, per `OnboardingOtherField.preferenceKey`.
  final Map<String, String> texts;

  Set<String> selectionsOf(String stepKey) => selections[stepKey] ?? const {};

  bool isSelected(String stepKey, String optionKey) =>
      selectionsOf(stepKey).contains(optionKey);

  String textOf(String preferenceKey) => texts[preferenceKey] ?? '';

  /// Body mass index, rounded to one decimal like the mockup ("23,5").
  double get bmi {
    final heightM = heightCm / 100;
    return double.parse((weightKg / (heightM * heightM)).toStringAsFixed(1));
  }

  BmiCategory get bmiCategory => bmiCategoryOf(bmi);

  OnboardingAnswers copyWith({
    Map<String, Set<String>>? selections,
    UserGender? gender,
    int? heightCm,
    int? weightKg,
    Map<String, String>? texts,
  }) {
    return OnboardingAnswers(
      selections: selections ?? this.selections,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      texts: texts ?? this.texts,
    );
  }

  @override
  List<Object?> get props => [
    // Sets are compared by value, but the map has to be rebuilt on every
    // change for Equatable to notice — the controller never mutates in place.
    // An unanswered step and a step with an empty answer are the same thing.
    {
      for (final entry in selections.entries)
        if (entry.value.isNotEmpty) entry.key: entry.value.toList()..sort(),
    },
    gender,
    heightCm,
    weightKg,
    // Same for an untouched field and an empty one.
    {
      for (final entry in texts.entries)
        if (entry.value.isNotEmpty) entry.key: entry.value,
    },
  ];
}
