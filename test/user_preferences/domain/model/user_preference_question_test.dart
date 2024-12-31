import 'package:flutter_test/flutter_test.dart';
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
                options: const ['option1', 'option2'],
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
                options: const ['option1', 'option2'],
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
            options: const ['option1', 'option2'],
          );

          question.answer('option1');

          final result = question.isOptionSelected('option1');

          expect(result, true);
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
            options: const ['option1', 'option2', 'option3'],
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
