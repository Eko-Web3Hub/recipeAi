import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/user_preferences/application/user_preference_service.dart';
import 'package:recipe_ai/user_preferences/domain/model/onboarding_answers.dart';
import 'package:recipe_ai/user_preferences/domain/model/onboarding_step.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/user_preference_repository.dart';
import 'package:recipe_ai/user_preferences/presentation/onboarding_preference_mapper.dart';
import 'package:recipe_ai/user_preferences/presentation/onboarding_quizz_controller.dart';

import '../bundled_onboarding_catalogue.dart';

class _UserPreferenceRepositoryMock extends Mock
    implements IUserPreferenceRepository {}

class _AuthUserServiceMock extends Mock implements IAuthUserService {}

class _AuthUserMock extends Mock implements AuthUser {}

void main() {
  late _UserPreferenceRepositoryMock repository;
  late _AuthUserServiceMock authUserService;
  late UserPreferenceService userPreferenceService;

  const uid = EntityId('uid');
  final catalogue = bundledCatalogue();

  setUpAll(() {
    registerFallbackValue(uid);
    registerFallbackValue(const UserPreference({}));
  });

  setUp(() {
    repository = _UserPreferenceRepositoryMock();
    authUserService = _AuthUserServiceMock();
    userPreferenceService = UserPreferenceService(repository);

    final user = _AuthUserMock();
    when(() => user.uid).thenReturn(uid);
    when(() => authUserService.currentUser).thenReturn(user);
    when(() => repository.save(any(), any())).thenAnswer((_) async {});
  });

  OnboardingQuizzController buildSut({OnboardingAnswers? initialAnswers}) =>
      OnboardingQuizzController(
        userPreferenceService,
        authUserService,
        steps: catalogue,
        initialAnswers: initialAnswers,
      );

  /// Answers every required step with a minimal valid answer.
  void answerRequiredSteps(OnboardingQuizzController sut) {
    sut.toggleOption(dietStepKey, 'no_restriction');
    sut.setGender(UserGender.female);
    sut.toggleOption(activityStepKey, 'sedentary');
    sut.toggleOption(goalsStepKey, 'detox');
    sut.toggleOption(chronicDiseaseStepKey, 'no_chronic_disease');
  }

  group('navigation', () {
    test('starts on the first step and cannot go back further', () {
      final sut = buildSut();

      expect(sut.state.currentIndex, 0);
      sut.previous();
      expect(sut.state.currentIndex, 0);
    });

    test('cannot go past the last step', () {
      final sut = buildSut();
      answerRequiredSteps(sut);

      for (var i = 0; i < catalogue.length + 2; i++) {
        sut.next();
      }

      expect(sut.state.currentIndex, catalogue.length - 1);
    });
  });

  group('required steps', () {
    test('cannot leave the diet step without a selection', () {
      final sut = buildSut();

      expect(sut.canContinue, isFalse);
      sut.next();
      expect(sut.state.currentIndex, 0);

      sut.toggleOption(dietStepKey, 'vegetarian');
      expect(sut.canContinue, isTrue);
      sut.next();
      expect(sut.state.currentIndex, 1);
    });

    test('cannot leave the morphology step without a gender', () {
      final sut = buildSut();
      sut.toggleOption(dietStepKey, 'vegetarian');
      sut.next();

      expect(sut.currentStep.kind, OnboardingStepKind.morphology);
      expect(sut.canContinue, isFalse);

      sut.setGender(UserGender.male);
      expect(sut.canContinue, isTrue);
    });

    test('unselecting the last option blocks the step again', () {
      final sut = buildSut();

      sut.toggleOption(dietStepKey, 'vegan');
      sut.toggleOption(dietStepKey, 'vegan');

      expect(sut.canContinue, isFalse);
    });

    test('the chronic disease step accepts "aucune" or a free text', () {
      final sut = buildSut();
      final step = catalogue.firstWhere(
        (step) => step.key == chronicDiseaseStepKey,
      );

      expect(sut.isStepComplete(step), isFalse);

      sut.setText(chronicDiseaseOtherPreferenceKey, '   ');
      expect(sut.isStepComplete(step), isFalse);

      sut.setText(chronicDiseaseOtherPreferenceKey, 'asthme');
      expect(sut.isStepComplete(step), isTrue);

      sut.setText(chronicDiseaseOtherPreferenceKey, '');
      sut.toggleOption(chronicDiseaseStepKey, 'diabetes');
      sut.toggleOption(chronicDiseaseStepKey, 'no_chronic_disease');
      expect(sut.state.answers.selectionsOf(chronicDiseaseStepKey), {
        'no_chronic_disease',
      });
      expect(sut.isStepComplete(step), isTrue);
    });

    test('the dietary preferences step is optional', () {
      final sut = buildSut();
      final step = catalogue.firstWhere(
        (step) => step.key == dietaryPreferencesStepKey,
      );

      expect(sut.isStepComplete(step), isTrue);
    });

    test('the dietary preferences come right before the chronic disease', () {
      final keys = catalogue.map((step) => step.key).toList();

      expect(
        keys.indexOf(dietaryPreferencesStepKey),
        keys.indexOf(chronicDiseaseStepKey) - 1,
      );
    });

    test('does not submit while a required step is unanswered', () async {
      final sut = buildSut();
      sut.toggleOption(dietStepKey, 'vegan');

      await sut.submit();

      verifyNever(() => repository.save(any(), any()));
      expect(sut.state.status, OnboardingQuizzStatus.editing);
    });
  });

  group('selection', () {
    test('a multiple choice step toggles its options', () {
      final sut = buildSut();

      sut.toggleOption(dietStepKey, 'vegetarian');
      sut.toggleOption(dietStepKey, 'gluten_free');
      expect(sut.state.answers.selectionsOf(dietStepKey), {
        'vegetarian',
        'gluten_free',
      });

      sut.toggleOption(dietStepKey, 'vegetarian');
      expect(sut.state.answers.selectionsOf(dietStepKey), {'gluten_free'});
    });

    test('"aucune restriction" and the other diets exclude each other', () {
      final sut = buildSut();

      sut.toggleOption(dietStepKey, 'vegetarian');
      sut.toggleOption(dietStepKey, 'no_restriction');
      expect(sut.state.answers.selectionsOf(dietStepKey), {'no_restriction'});

      sut.toggleOption(dietStepKey, 'vegan');
      expect(sut.state.answers.selectionsOf(dietStepKey), {'vegan'});
    });

    test('a single choice step replaces its selection', () {
      final sut = buildSut();

      sut.toggleOption(activityStepKey, 'sedentary');
      sut.toggleOption(activityStepKey, 'athlete');

      expect(sut.state.answers.selectionsOf(activityStepKey), {'athlete'});
    });
  });

  group('morphology', () {
    test('computes the BMI of the mockup defaults', () {
      final sut = buildSut();

      expect(sut.state.answers.bmi, 23.5);
      expect(sut.state.answers.bmiCategory, BmiCategory.normal);
    });

    test('clamps height and weight to a plausible range', () {
      final sut = buildSut();

      sut.setHeight(10);
      sut.setWeight(1000);

      expect(sut.state.answers.heightCm, OnboardingAnswers.minHeightCm);
      expect(sut.state.answers.weightKg, OnboardingAnswers.maxWeightKg);
    });
  });

  group('submit', () {
    test('writes every option key plus the typed fields', () async {
      final sut = buildSut();

      answerRequiredSteps(sut);
      sut.toggleOption(dietStepKey, 'vegan');
      sut.toggleOption(activityStepKey, 'athlete');
      sut.toggleOption(dietaryPreferencesStepKey, 'halal');
      sut.setText(chronicDiseaseOtherPreferenceKey, '  asthme ');
      sut.setText(dislikedFoodsPreferenceKey, ' olives ');

      await sut.submit();

      final saved =
          verify(() => repository.save(uid, captureAny())).captured.single
              as UserPreference;

      expect(saved.preferences['vegan'], true);
      expect(saved.preferences['vegetarian'], false);
      expect(saved.preferences['athlete'], true);
      expect(saved.preferences['sedentary'], false);
      expect(saved.preferences[genderPreferenceKey], 'female');
      expect(saved.preferences[heightPreferenceKey], 170);
      expect(saved.preferences[bmiPreferenceKey], 23.5);
      expect(saved.preferences[chronicDiseaseOtherPreferenceKey], 'asthme');
      expect(saved.preferences['halal'], true);
      expect(saved.preferences['allergy_egg'], false);
      expect(saved.preferences[dislikedFoodsPreferenceKey], 'olives');
      expect(sut.state.status, OnboardingQuizzStatus.success);

      // Every option of the catalogue is written, so the backend never sees a
      // missing key.
      for (final key in allOptionKeysOf(catalogue)) {
        expect(saved.preferences.containsKey(key), isTrue, reason: key);
      }
    });

    test('reports an error and stays editable when the save fails', () async {
      when(() => repository.save(any(), any())).thenThrow(Exception('boom'));
      final sut = buildSut();
      answerRequiredSteps(sut);

      await sut.submit();

      expect(sut.state.status, OnboardingQuizzStatus.editing);
    });
  });

  group('mapper', () {
    test('rebuilds the answers from a saved document', () {
      final sut = buildSut();
      sut.toggleOption(dietStepKey, 'lactose_free');
      sut.toggleOption(chronicDiseaseStepKey, 'diabetes');
      sut.setGender(UserGender.other);
      sut.setHeight(180);
      sut.setWeight(75);
      sut.setText(chronicDiseaseOtherPreferenceKey, 'asthme');
      sut.toggleOption(dietaryPreferencesStepKey, 'allergy_soy');
      sut.setText(dislikedFoodsPreferenceKey, 'coriandre');

      final restored = answersFrom(
        buildUserPreferenceFrom(sut.state.answers, steps: catalogue),
        steps: catalogue,
      );

      expect(restored, sut.state.answers);
    });

    test('falls back to the defaults on a legacy document', () {
      final restored = answersFrom(
        const UserPreference({'Halal': true}),
        steps: catalogue,
      );

      expect(restored.gender, isNull);
      expect(restored.heightCm, OnboardingAnswers.defaultHeightCm);
      expect(restored.weightKg, OnboardingAnswers.defaultWeightKg);
      expect(restored.selectionsOf(dietStepKey), isEmpty);
    });
  });
}
