import 'package:recipe_ai/user_preferences/domain/model/onboarding_step.dart';

abstract class IOnboardingQuizzRepository {
  /// The enabled steps of the onboarding quizz, in display order. Never empty:
  /// falls back on the catalogue bundled with the app.
  Future<List<OnboardingStep>> retrieve();
}
