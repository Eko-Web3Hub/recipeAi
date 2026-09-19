import 'package:recipe_ai/user_preferences/domain/model/onboarding_step.dart';

/// Reads the onboarding catalogue documents. The documents are edited by hand
/// in the Firestore console, so the parsing is lenient: a malformed option is
/// dropped, an unknown value falls back on the default, and a step that cannot
/// be shown is skipped rather than breaking the onboarding.
abstract class OnboardingStepSerialization {
  /// Parses a `{stepKey: stepDocument}` map into the ordered, enabled steps.
  static List<OnboardingStep> catalogueFromJson(Map<String, dynamic> json) {
    final entries = <({int order, OnboardingStep step})>[];
    for (final entry in json.entries) {
      final data = _map(entry.value);
      if (data == null) continue;
      if (data['enabled'] == false) continue;

      final step = fromJson(entry.key, data);
      if (step == null) continue;
      entries.add((order: _int(data['order']) ?? 0, step: step));
    }
    // Stable sort: steps sharing an order keep the document order.
    final indexed = entries.indexed.toList()
      ..sort((a, b) {
        final byOrder = a.$2.order.compareTo(b.$2.order);
        return byOrder != 0 ? byOrder : a.$1.compareTo(b.$1);
      });
    return [for (final (_, entry) in indexed) entry.step];
  }

  /// Returns null when the step cannot be shown: unknown kind, no title, or
  /// an option step without any valid option.
  static OnboardingStep? fromJson(String key, Map<String, dynamic> json) {
    final kind = _enum(OnboardingStepKind.values, json['kind']);
    final title = _localized(json['title']);
    if (kind == null || title == null) return null;

    final options = _options(json['options']);
    final sections = <OnboardingOptionSection>[
      if (json['sections'] case final List<dynamic> rawSections)
        for (final rawSection in rawSections)
          if (_section(rawSection) case final section?) section,
    ];

    final hasOptions = options.isNotEmpty || sections.isNotEmpty;
    if (kind == OnboardingStepKind.options && options.isEmpty) return null;
    if (kind == OnboardingStepKind.chips && !hasOptions) return null;

    return OnboardingStep(
      key: key,
      kind: kind,
      title: title,
      helper: _localized(json['helper']) ?? const LocalizedString({}),
      selectionMode:
          _enum(OptionSelectionMode.values, json['selectionMode']) ??
          OptionSelectionMode.multiple,
      tileStyle:
          _enum(OptionTileStyle.values, json['tileStyle']) ??
          OptionTileStyle.colorDot,
      options: options,
      sections: sections,
      exclusiveOptionKey: _string(json['exclusiveOptionKey']),
      otherField: _otherField(json['otherField']),
      isRequired: json['isRequired'] != false,
      footnote: _localized(json['footnote']),
    );
  }

  static OnboardingOptionSection? _section(dynamic raw) {
    final json = _map(raw);
    if (json == null) return null;
    final title = _localized(json['title']);
    final options = _options(json['options']);
    if (title == null || options.isEmpty) return null;
    return OnboardingOptionSection(title: title, options: options);
  }

  static List<OnboardingOption> _options(dynamic json) {
    if (json is! List<dynamic>) return const [];
    return [
      for (final raw in json)
        if (_option(raw) case final option?) option,
    ];
  }

  static OnboardingOption? _option(dynamic raw) {
    final json = _map(raw);
    if (json == null) return null;
    final key = _string(json['key']);
    final label = _localized(json['label']);
    if (key == null || label == null) return null;

    return OnboardingOption(
      key: key,
      label: label,
      description: _localized(json['description']),
      color: _string(json['color']),
      icon: _string(json['icon']),
    );
  }

  static OnboardingOtherField? _otherField(dynamic raw) {
    final json = _map(raw);
    if (json == null) return null;
    final preferenceKey = _string(json['preferenceKey']);
    if (preferenceKey == null) return null;

    return OnboardingOtherField(
      preferenceKey: preferenceKey,
      hint: _localized(json['hint']) ?? const LocalizedString({}),
      title: _localized(json['title']),
    );
  }

  /// `{fr: …, en: …}`, or a plain string used for every language.
  static LocalizedString? _localized(dynamic json) {
    if (json is String && json.trim().isNotEmpty) {
      return LocalizedString({'en': json});
    }
    if (json is! Map) return null;
    final translations = <String, String>{
      for (final entry in json.entries)
        if (entry.key is String &&
            entry.value is String &&
            (entry.value as String).trim().isNotEmpty)
          entry.key as String: entry.value as String,
    };
    return translations.isEmpty ? null : LocalizedString(translations);
  }

  /// Nested Firestore maps are not always typed `Map<String, dynamic>`.
  static Map<String, dynamic>? _map(dynamic value) {
    if (value is! Map) return null;
    return {
      for (final entry in value.entries)
        if (entry.key is String) entry.key as String: entry.value,
    };
  }

  static T? _enum<T extends Enum>(List<T> values, dynamic name) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }

  static String? _string(dynamic value) =>
      value is String && value.trim().isNotEmpty ? value.trim() : null;

  static int? _int(dynamic value) => value is num ? value.toInt() : null;
}
