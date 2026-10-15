import 'dart:convert';
import 'dart:io';

import 'package:recipe_ai/user_preferences/domain/model/onboarding_step.dart';
import 'package:recipe_ai/user_preferences/infrastructure/onboarding_quizz_repository.dart';
import 'package:recipe_ai/user_preferences/infrastructure/serialization/onboarding_step_serialization.dart';

const dietStepKey = 'diet_profile';
const activityStepKey = 'activity_level';
const goalsStepKey = 'goals';
const dietaryPreferencesStepKey = 'dietary_preferences';

/// The "Un point d'attention pour tes repas ?" step, which kept the key of
/// the former chronic disease step.
const chronicDiseaseStepKey = 'chronic_disease';

const healthDataConsentKey = 'healthDataConsent';
const dislikedFoodsPreferenceKey = 'dislikedFoods';

/// Raw content of the catalogue bundled with the app (and seeded to
/// Firestore). Tests run from the project root.
String bundledCatalogueSource() =>
    File(onboardingQuizzAssetPath).readAsStringSync();

Map<String, dynamic> bundledCatalogueJson() =>
    jsonDecode(bundledCatalogueSource()) as Map<String, dynamic>;

List<OnboardingStep> bundledCatalogue() =>
    OnboardingStepSerialization.catalogueFromJson(bundledCatalogueJson());
