import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/presentation/auth_navigation_controller.dart';
import 'package:recipe_ai/auth/presentation/components/custom_snack_bar.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/user_preferences/application/user_preference_service.dart';
import 'package:recipe_ai/user_preferences/domain/model/onboarding_step.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/onboarding_quizz_repository.dart';
import 'package:recipe_ai/user_preferences/presentation/components/custom_progress.dart';
import 'package:recipe_ai/user_preferences/presentation/components/onboarding_step_scaffold.dart';
import 'package:recipe_ai/user_preferences/presentation/onboarding_catalogue_controller.dart';
import 'package:recipe_ai/user_preferences/presentation/onboarding_display.dart';
import 'package:recipe_ai/user_preferences/presentation/onboarding_quizz_controller.dart';
import 'package:recipe_ai/user_preferences/presentation/steps/chips_step.dart';
import 'package:recipe_ai/user_preferences/presentation/steps/morphology_step.dart';
import 'package:recipe_ai/user_preferences/presentation/steps/option_list_step.dart';

/// Paginated onboarding quizz: one step per screen, submitted at the last one.
class UserPreferencesView extends StatelessWidget {
  const UserPreferencesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          OnboardingCatalogueController(di<IOnboardingQuizzRepository>()),
      child: BlocBuilder<OnboardingCatalogueController, List<OnboardingStep>?>(
        builder: (context, steps) {
          if (steps == null) {
            return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(child: CustomProgress()),
            );
          }

          return BlocProvider(
            create: (_) => OnboardingQuizzController(
              di<UserPreferenceService>(),
              di<IAuthUserService>(),
              steps: steps,
            ),
            child: const _UserPreferencesBody(),
          );
        },
      ),
    );
  }
}

class _UserPreferencesBody extends StatelessWidget {
  const _UserPreferencesBody();

  @override
  Widget build(BuildContext context) {
    final controller = context.read<OnboardingQuizzController>();
    final appTexts = di<TranslationController>().currentLanguage;

    return BlocConsumer<OnboardingQuizzController, OnboardingQuizzState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == OnboardingQuizzStatus.success) {
          context.read<AuthNavigationController>().preferencesCompleted();
          context.go('/home');
        }
        if (state.status == OnboardingQuizzStatus.error) {
          showSnackBar(context, appTexts.somethingWentWrong, isError: true);
        }
      },
      builder: (context, state) {
        final step = controller.steps[state.currentIndex];
        final isLast = state.currentIndex == controller.steps.length - 1;

        return PopScope(
          canPop: state.currentIndex == 0,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) controller.previous();
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: OnboardingStepScaffold(
                currentStep: state.currentIndex + 1,
                totalSteps: controller.steps.length,
                title: step.title.text,
                helper: step.helper.text,
                footnote: step.footnote?.text,
                onBack: state.currentIndex == 0 ? null : controller.previous,
                isLoading: state.status == OnboardingQuizzStatus.submitting,
                ctaLabel: isLast
                    ? appTexts.finish
                    : appTexts.onboardingContinue,
                onCta: !controller.canContinue
                    ? null
                    : isLast
                    ? controller.submit
                    : controller.next,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: KeyedSubtree(
                    key: ValueKey(step.key),
                    child: _StepContent(step: step, state: state),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StepContent extends StatelessWidget {
  const _StepContent({required this.step, required this.state});

  final OnboardingStep step;
  final OnboardingQuizzState state;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<OnboardingQuizzController>();

    switch (step.kind) {
      case OnboardingStepKind.morphology:
        return MorphologyStep(
          answers: state.answers,
          onGenderChanged: controller.setGender,
          onHeightChanged: controller.setHeight,
          onWeightChanged: controller.setWeight,
        );
      case OnboardingStepKind.options:
        return OptionListStep(
          step: step,
          answers: state.answers,
          onToggle: (optionKey) => controller.toggleOption(step.key, optionKey),
          onTextChanged: controller.setText,
        );
      case OnboardingStepKind.chips:
        return ChipsStep(
          step: step,
          answers: state.answers,
          onToggle: (optionKey) => controller.toggleOption(step.key, optionKey),
          onTextChanged: controller.setText,
        );
    }
  }
}
