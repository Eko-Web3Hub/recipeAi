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
}
