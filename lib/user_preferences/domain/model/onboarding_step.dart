import 'package:equatable/equatable.dart';
import 'package:recipe_ai/utils/constant.dart';

/// Catalogue of the onboarding quizz. It is loaded from the `OnboardingQuizz`
/// Firestore collection (one document per step), with
/// `assets/data/onboarding_quizz.json` as offline fallback: adding an option
/// or a step is a data change, not a release.
///
/// Only the layouts stay in the code: [OnboardingStepKind] and
/// [OptionTileStyle]. A new kind of screen still needs a release.

enum OnboardingStepKind {
  /// A list of options to pick from.
  options,

  /// The gender / height / weight form with the BMI card.
  morphology,

  /// Titled sections of chips plus a free text field
  /// ("préférences diététiques").
  chips,
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

/// A text translated in every app language, stored as `{fr: …, en: …}`.
class LocalizedString extends Equatable {
  const LocalizedString(this.translations);

  final Map<String, String> translations;

  /// Falls back on English, then French, then any translation, so a missing
  /// translation in the console never shows an empty label.
  String resolve(AppLanguage language) =>
      translations[language.name] ??
      translations[AppLanguage.en.name] ??
      translations[AppLanguage.fr.name] ??
      translations.values.firstOrNull ??
      '';

  @override
  List<Object?> get props => [translations];
}

class OnboardingOption extends Equatable {
  const OnboardingOption({
    required this.key,
    required this.label,
    this.description,
    this.color,
    this.icon,
  });

  /// Stable, language independent key written to the user preferences.
  final String key;
  final LocalizedString label;
  final LocalizedString? description;

  /// `#RRGGBB`.
  final String? color;

  /// Name of an icon of the app registry (see `onboarding_icons.dart`).
  final String? icon;

  @override
  List<Object?> get props => [key, label, description, color, icon];
}

class OnboardingOptionSection extends Equatable {
  const OnboardingOptionSection({required this.title, required this.options});

  final LocalizedString title;
  final List<OnboardingOption> options;

  @override
  List<Object?> get props => [title, options];
}

/// Free text field of a step ("Autre", "Aliments que tu n'aimes pas").
class OnboardingOtherField extends Equatable {
  const OnboardingOtherField({
    required this.preferenceKey,
    required this.hint,
    this.title,
  });

  /// Key the trimmed text is written under in the user preferences.
  final String preferenceKey;
  final LocalizedString hint;

  /// Label above the field, when the step shows one.
  final LocalizedString? title;

  @override
  List<Object?> get props => [preferenceKey, hint, title];
}

class OnboardingStep extends Equatable {
  const OnboardingStep({
    required this.key,
    required this.title,
    required this.helper,
    this.kind = OnboardingStepKind.options,
    this.selectionMode = OptionSelectionMode.multiple,
    this.tileStyle = OptionTileStyle.colorDot,
    this.options = const [],
    this.sections = const [],
    this.exclusiveOptionKey,
    this.otherField,
    this.isRequired = true,
    this.footnote,
  });

  final String key;
  final LocalizedString title;
  final LocalizedString helper;
  final OnboardingStepKind kind;
  final OptionSelectionMode selectionMode;
  final OptionTileStyle tileStyle;
  final List<OnboardingOption> options;

  /// Chip sections of a [OnboardingStepKind.chips] step.
  final List<OnboardingOptionSection> sections;

  /// Option that clears every other one when picked, and is cleared by them
  /// ("Aucune restriction").
  final String? exclusiveOptionKey;

  final OnboardingOtherField? otherField;

  /// A required step has to be answered before moving on.
  final bool isRequired;
  final LocalizedString? footnote;

  /// Options of the step, whether listed flat or grouped in sections.
  List<OnboardingOption> get allOptions => [
    ...options,
    for (final section in sections) ...section.options,
  ];

  @override
  List<Object?> get props => [
    key,
    title,
    helper,
    kind,
    selectionMode,
    tileStyle,
    options,
    sections,
    exclusiveOptionKey,
    otherField,
    isRequired,
    footnote,
  ];
}
