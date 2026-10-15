import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_ai/user_preferences/domain/model/onboarding_step.dart';
import 'package:recipe_ai/user_preferences/infrastructure/serialization/onboarding_step_serialization.dart';
import 'package:recipe_ai/user_preferences/presentation/onboarding_display.dart';
import 'package:recipe_ai/utils/constant.dart';

import '../bundled_onboarding_catalogue.dart';

Map<String, dynamic> _optionStep({
  int order = 1,
  List<dynamic>? options,
  Object? kind = 'options',
}) => {
  'order': order,
  'kind': kind,
  'title': {'fr': 'Titre', 'en': 'Title'},
  'helper': {'fr': 'Aide', 'en': 'Help'},
  'options':
      options ??
      [
        {
          'key': 'a',
          'label': {'fr': 'A', 'en': 'A'},
        },
      ],
};

void main() {
  group('bundled catalogue', () {
    final catalogue = bundledCatalogue();

    test('parses every step, in order', () {
      expect(catalogue.map((step) => step.key), [
        dietStepKey,
        'morphology',
        activityStepKey,
        goalsStepKey,
        dietaryPreferencesStepKey,
        chronicDiseaseStepKey,
      ]);
    });

    test('option keys are unique across the catalogue', () {
      final keys = [
        for (final step in catalogue)
          for (final option in step.allOptions) option.key,
      ];

      expect(keys.toSet().length, keys.length);
    });

    test('every text is translated in every app language', () {
      final texts = <LocalizedString>[
        for (final step in catalogue) ...[
          step.title,
          step.helper,
          ?step.footnote,
          ?step.otherField?.hint,
          ?step.otherField?.title,
          ?step.consent?.label,
          for (final section in step.sections) section.title,
          for (final option in step.allOptions) ...[
            option.label,
            ?option.description,
          ],
        ],
      ];

      for (final text in texts) {
        for (final language in AppLanguage.values) {
          expect(
            text.translations[language.name],
            isNotEmpty,
            reason: '${text.translations} misses ${language.name}',
          );
        }
      }
    });

    test('every icon is in the app registry', () {
      for (final step in catalogue) {
        for (final option in step.allOptions) {
          if (option.icon case final icon?) {
            expect(onboardingIcons.containsKey(icon), isTrue, reason: icon);
          }
        }
      }
    });
  });

  group('lenient parsing', () {
    test('skips disabled steps and sorts by order', () {
      final steps = OnboardingStepSerialization.catalogueFromJson({
        'second': _optionStep(order: 2),
        'hidden': {..._optionStep(order: 0), 'enabled': false},
        'first': _optionStep(order: 1),
      });

      expect(steps.map((step) => step.key), ['first', 'second']);
    });

    test('skips a step of an unknown kind or without valid option', () {
      final steps = OnboardingStepSerialization.catalogueFromJson({
        'future_kind': _optionStep(kind: 'slider'),
        'no_option': _optionStep(options: []),
        'broken_options': _optionStep(
          options: [
            'not a map',
            {'key': 'no_label'},
          ],
        ),
        'not_a_map': 'oops',
        'ok': _optionStep(),
      });

      expect(steps.map((step) => step.key), ['ok']);
    });

    test('falls back on defaults for unknown values', () {
      final step = OnboardingStepSerialization.fromJson('step', {
        ..._optionStep(),
        'selectionMode': 'many',
        'tileStyle': 'hexagon',
      })!;

      expect(step.selectionMode, OptionSelectionMode.multiple);
      expect(step.tileStyle, OptionTileStyle.colorDot);
      expect(step.isRequired, isTrue);
    });

    test('accepts untyped nested maps, as Firestore may return them', () {
      final step = OnboardingStepSerialization.fromJson('step', {
        'kind': 'options',
        'title': <Object?, Object?>{'fr': 'Titre'},
        'options': [
          <Object?, Object?>{
            'key': 'a',
            'label': <Object?, Object?>{'fr': 'A'},
          },
        ],
      });

      expect(step?.options.single.key, 'a');
    });
  });

  group('LocalizedString', () {
    test('falls back on English then French', () {
      expect(
        const LocalizedString({
          'en': 'Hello',
          'fr': 'Salut',
        }).resolve(AppLanguage.fr),
        'Salut',
      );
      expect(
        const LocalizedString({'en': 'Hello'}).resolve(AppLanguage.fr),
        'Hello',
      );
      expect(
        const LocalizedString({'fr': 'Salut'}).resolve(AppLanguage.en),
        'Salut',
      );
    });
  });

  group('display helpers', () {
    test('parses hex colors and falls back on malformed ones', () {
      expect(onboardingColorOf('#C96F4A').toARGB32(), 0xFFC96F4A);
      expect(onboardingColorOf('C96F4A').toARGB32(), 0xFFC96F4A);
      expect(onboardingColorOf('#zzz'), onboardingColorOf(null));
    });
  });

  group('meal focus step', () {
    final step = bundledCatalogue().firstWhere(
      (step) => step.key == chronicDiseaseStepKey,
    );

    test('is optional, without "aucune" nor free text', () {
      expect(step.isRequired, isFalse);
      expect(step.exclusiveOptionKey, isNull);
      expect(step.otherField, isNull);
    });

    test('keeps the option keys read by the backend', () {
      expect(step.options.map((option) => option.key), [
        'diabetes',
        'hypertension',
        'cardiovascular_disease',
        'overweight',
        'smop',
        'anti_inflammatory',
        'mass_gain',
      ]);
      for (final option in step.options) {
        expect(option.description, isNotNull, reason: option.key);
      }
    });

    test('asks for the health data consent', () {
      expect(step.consent?.preferenceKey, healthDataConsentKey);
    });
  });

  group('consent', () {
    test('is read with its preference key and label', () {
      final step = OnboardingStepSerialization.fromJson('health', {
        ..._optionStep(),
        'consent': {
          'preferenceKey': 'healthDataConsent',
          'label': {'fr': "J'accepte", 'en': 'I agree'},
        },
      });

      expect(
        step!.consent,
        const OnboardingConsent(
          preferenceKey: 'healthDataConsent',
          label: LocalizedString({'fr': "J'accepte", 'en': 'I agree'}),
        ),
      );
    });

    test('is dropped when it misses its key or label', () {
      for (final consent in [
        {'preferenceKey': 'healthDataConsent'},
        {
          'label': {'fr': "J'accepte"},
        },
        'yes',
      ]) {
        final step = OnboardingStepSerialization.fromJson('health', {
          ..._optionStep(),
          'consent': consent,
        });

        expect(step!.consent, isNull, reason: '$consent');
      }
    });
  });
}
