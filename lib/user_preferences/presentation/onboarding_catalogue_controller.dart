import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/user_preferences/domain/model/onboarding_step.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/onboarding_quizz_repository.dart';
import 'package:recipe_ai/utils/safe_emit.dart';

/// Loads the onboarding catalogue. `null` while loading.
class OnboardingCatalogueController extends Cubit<List<OnboardingStep>?> {
  OnboardingCatalogueController(this._repository) : super(null) {
    _load();
  }

  final IOnboardingQuizzRepository _repository;

  Future<void> _load() async => safeEmit(await _repository.retrieve());
}
