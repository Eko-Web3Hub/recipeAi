import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_ai/user_preferences/infrastructure/onboarding_quizz_repository.dart';

import '../bundled_onboarding_catalogue.dart';

void main() {
  late FakeFirebaseFirestore firestore;

  setUp(() {
    firestore = FakeFirebaseFirestore();
  });

  FirestoreOnboardingQuizzRepository buildSut() =>
      FirestoreOnboardingQuizzRepository(
        firestore,
        loadAsset: (_) async => bundledCatalogueSource(),
      );

  Future<void> seed(Map<String, dynamic> catalogue) async {
    for (final entry in catalogue.entries) {
      await firestore
          .collection('OnboardingQuizz')
          .doc(entry.key)
          .set(entry.value as Map<String, dynamic>);
    }
  }

  test(
    'falls back on the bundled catalogue when the collection is empty',
    () async {
      final steps = await buildSut().retrieve();

      expect(steps, bundledCatalogue());
    },
  );

  test('reads the seeded catalogue like the bundled one', () async {
    await seed(bundledCatalogueJson());

    final steps = await buildSut().retrieve();

    expect(steps, bundledCatalogue());
  });

  test(
    'follows the console edits: new option, hidden step, new order',
    () async {
      final json = bundledCatalogueJson();
      (json[goalsStepKey]['options'] as List<dynamic>).add({
        'key': 'better_sleep',
        'label': {'fr': 'Mieux dormir', 'en': 'Sleep better'},
        'icon': 'bedtime_outlined',
      });
      json[dietaryPreferencesStepKey]['enabled'] = false;
      json[goalsStepKey]['order'] = 0;
      await seed(json);

      final steps = await buildSut().retrieve();

      expect(steps.first.key, goalsStepKey);
      expect(steps.first.options.last.key, 'better_sleep');
      expect(
        steps.map((step) => step.key),
        isNot(contains(dietaryPreferencesStepKey)),
      );
    },
  );
}
