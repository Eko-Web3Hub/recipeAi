import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference_question.dart';

void main() {
  group(
    'userPreferenceQuestionTypeFromString methods',
    () {
      test(
        'should return MultipleChoice question',
        () {
          const type = 'multipleChoice';

          final result = userPreferenceQuestionTypeFromString(type);

          expect(result, UserPreferenceQuestionType.multipleChoice);
        },
      );

      test(
        'should throw UnimplementedError',
        () {
          const type = 'invalid';

          expect(
            () => userPreferenceQuestionTypeFromString(type),
            throwsA(isA<UnimplementedError>()),
          );
        },
      );
    },
  );

  group(
    ' UserPreferenceQuestionMultipleChoice class',
    () {
      group(
        'answer method',
        () {
          test(
            'should add option to selectedOptions',
            () {
              final question = UserPreferenceQuestionMultipleChoice(
                title: 'title',
                description: 'description',
                type: UserPreferenceQuestionType.multipleChoice,
                options: const [
                  Option(label: 'option1', key: 'option1'),
                  Option(label: 'option2', key: 'option2'),
                ],
              );

              question.answer('option1');

              expect(question.selectedOptions, ['option1']);
            },
          );

          test(
            'should remove selected option',
            () {
              final question = UserPreferenceQuestionMultipleChoice(
                title: 'title',
                description: 'description',
                type: UserPreferenceQuestionType.multipleChoice,
                options: const [
                  Option(label: 'option1', key: 'option1'),
                  Option(label: 'option2', key: 'option2'),
                ],
              );

              question.answer('option1');
              question.answer('option1');

              expect(question.selectedOptions, []);
            },
          );
        },
      );
    },
  );

  group(
    'isOptionSelected method',
    () {
      test(
        'should return true',
        () {
          final question = UserPreferenceQuestionMultipleChoice(
            title: 'title',
            description: 'description',
            type: UserPreferenceQuestionType.multipleChoice,
            options: const [
              Option(label: 'option1', key: 'option1'),
              Option(label: 'option2', key: 'option2')
            ],
          );

          question.answer('option1');

          final result = question.isOptionSelected('option1');

          expect(result, true);
        },
      );
    },
  );

  group(
    'initWithUserPreference method',
    () {
      test(
        'should initialise the qestion with user preference',
        () {
          final question = UserPreferenceQuestionMultipleChoice(
            title: 'title',
            description: 'description',
            type: UserPreferenceQuestionType.multipleChoice,
            options: const [
              Option(label: 'African', key: 'African'),
              Option(label: 'Halal', key: 'Halal'),
              Option(label: 'French', key: 'French'),
            ],
          );
          const userPreference = UserPreference(
            {
              'African': true,
              'Halal': false,
              'French': true,
            },
          );

          final result = question.initWithUserPreference(userPreference);

          expect(result.title, question.title);
          expect(result.description, question.description);
          expect(result.type, question.type);
          expect(result.options, question.options);
          expect(result.selectedOptions, ['African', 'French']);
        },
      );
    },
  );

  group(
    'toJson method',
    () {
      test(
        'should return json',
        () {
          final question = UserPreferenceQuestionMultipleChoice(
            title: 'title',
            description: 'description',
            type: UserPreferenceQuestionType.multipleChoice,
            options: const [
              Option(label: 'option1', key: 'option1'),
              Option(label: 'option2', key: 'option2'),
              Option(label: 'option3', key: 'option3'),
            ],
          );

          question.answer('option1');
          question.answer('option2');

          final result = question.toJson();

          expect(result, {
            'option1': true,
            'option2': true,
            'option3': false,
          });
        },
      );
    },
  );
}
