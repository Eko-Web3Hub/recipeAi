import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/user_preferences/application/user_preference_service.dart';
import 'package:recipe_ai/user_preferences/domain/model/onboarding_answers.dart';
import 'package:recipe_ai/user_preferences/presentation/onboarding_preference_mapper.dart';
import 'package:recipe_ai/user_preferences/presentation/onboarding_steps.dart';
import 'package:recipe_ai/utils/safe_emit.dart';

enum OnboardingQuizzStatus { editing, submitting, success, error }

class OnboardingQuizzState extends Equatable {
  const OnboardingQuizzState({
    this.currentIndex = 0,
    this.answers = const OnboardingAnswers(),
    this.status = OnboardingQuizzStatus.editing,
  });

  final int currentIndex;
  final OnboardingAnswers answers;
  final OnboardingQuizzStatus status;

  OnboardingQuizzState copyWith({
    int? currentIndex,
    OnboardingAnswers? answers,
    OnboardingQuizzStatus? status,
  }) {
    return OnboardingQuizzState(
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [currentIndex, answers, status];
}

/// Drives the paginated onboarding quizz: one step per screen, the answers are
/// only written to Firestore once the last step is validated.
class OnboardingQuizzController extends Cubit<OnboardingQuizzState> {
  OnboardingQuizzController(
    this._userPreferenceService,
    this._authUserService, {
    List<OnboardingStep>? steps,
    OnboardingAnswers? initialAnswers,
  }) : steps = steps ?? onboardingSteps,
       super(
         OnboardingQuizzState(
           answers: initialAnswers ?? const OnboardingAnswers(),
         ),
       );

  final UserPreferenceService _userPreferenceService;
  final IAuthUserService _authUserService;
  final List<OnboardingStep> steps;

  OnboardingStep get currentStep => steps[state.currentIndex];
  bool get isLastStep => state.currentIndex >= steps.length - 1;
  bool get isFirstStep => state.currentIndex == 0;

  void toggleOption(String stepKey, String optionKey) {
    final step = steps.firstWhere((step) => step.key == stepKey);
    final current = state.answers.selectionsOf(stepKey);

    Set<String> updated;
    if (step.selectionMode == OptionSelectionMode.single) {
      updated = {optionKey};
    } else if (optionKey == step.exclusiveOptionKey) {
      // "Aucune restriction" clears everything else.
      updated = current.contains(optionKey) ? {} : {optionKey};
    } else {
      updated = {...current, optionKey};
      if (current.contains(optionKey)) {
        updated.remove(optionKey);
      }
      updated.remove(step.exclusiveOptionKey);
    }

    _emitAnswers(
      state.answers.copyWith(
        selections: {...state.answers.selections, stepKey: updated},
      ),
    );
  }

  void setGender(UserGender gender) =>
      _emitAnswers(state.answers.copyWith(gender: gender));

  void setHeight(int heightCm) => _emitAnswers(
    state.answers.copyWith(
      heightCm: heightCm.clamp(
        OnboardingAnswers.minHeightCm,
        OnboardingAnswers.maxHeightCm,
      ),
    ),
  );

  void setWeight(int weightKg) => _emitAnswers(
    state.answers.copyWith(
      weightKg: weightKg.clamp(
        OnboardingAnswers.minWeightKg,
        OnboardingAnswers.maxWeightKg,
      ),
    ),
  );

  void setChronicDiseaseOther(String value) =>
      _emitAnswers(state.answers.copyWith(chronicDiseaseOther: value));

  void next() {
    if (isLastStep) return;
    safeEmit(state.copyWith(currentIndex: state.currentIndex + 1));
  }

  void previous() {
    if (isFirstStep) return;
    safeEmit(state.copyWith(currentIndex: state.currentIndex - 1));
  }

  Future<void> submit() async {
    safeEmit(state.copyWith(status: OnboardingQuizzStatus.submitting));
    try {
      final uid = _authUserService.currentUser!.uid;
      await _userPreferenceService.saveUserPreference(
        uid,
        buildUserPreferenceFrom(state.answers, steps: steps),
      );
      safeEmit(state.copyWith(status: OnboardingQuizzStatus.success));
    } catch (_) {
      safeEmit(state.copyWith(status: OnboardingQuizzStatus.error));
      safeEmit(state.copyWith(status: OnboardingQuizzStatus.editing));
    }
  }

  void _emitAnswers(OnboardingAnswers answers) =>
      safeEmit(state.copyWith(answers: answers));
}
