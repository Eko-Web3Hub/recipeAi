import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/presentation/components/custom_snack_bar.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/home/presentation/home_screen_controller.dart';
import 'package:recipe_ai/receipe/application/user_recipe_service.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/user_preferences/application/user_preference_service.dart';
import 'package:recipe_ai/user_preferences/domain/model/onboarding_answers.dart';
import 'package:recipe_ai/user_preferences/domain/model/onboarding_step.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/onboarding_quizz_repository.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/user_preference_repository.dart';
import 'package:recipe_ai/user_preferences/presentation/components/custom_progress.dart';
import 'package:recipe_ai/user_preferences/presentation/components/onboarding_primary_button.dart';
import 'package:recipe_ai/user_preferences/presentation/onboarding_display.dart';
import 'package:recipe_ai/user_preferences/presentation/onboarding_preference_mapper.dart';
import 'package:recipe_ai/user_preferences/presentation/onboarding_quizz_controller.dart';
import 'package:recipe_ai/user_preferences/presentation/steps/chips_step.dart';
import 'package:recipe_ai/user_preferences/presentation/steps/morphology_step.dart';
import 'package:recipe_ai/user_preferences/presentation/steps/option_list_step.dart';
import 'package:recipe_ai/user_preferences/presentation/user_preference_update_btn_controller.dart';
import 'package:recipe_ai/user_preferences/presentation/user_preference_update_controller.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

/// Profile screen: the onboarding questions again, all on one page and
/// pre-filled with what the user already answered.
class UserPreferenceUpdateWidget extends StatelessWidget {
  const UserPreferenceUpdateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserPreferenceUpdateController(
        di<IAuthUserService>(),
        di<IUserPreferenceRepository>(),
        di<IOnboardingQuizzRepository>(),
      ),
      child:
          BlocBuilder<
            UserPreferenceUpdateController,
            UserPreferenceUpdateState
          >(
            builder: (context, state) {
              if (state is! UserPreferenceUpdateLoaded) {
                return const Center(child: CustomProgress());
              }

              return _UserPreferenceForm(
                steps: state.steps,
                initialAnswers: state.answers,
              );
            },
          ),
    );
  }
}

class _UserPreferenceForm extends StatelessWidget {
  const _UserPreferenceForm({
    required this.steps,
    required this.initialAnswers,
  });

  final List<OnboardingStep> steps;
  final OnboardingAnswers initialAnswers;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => OnboardingQuizzController(
            di<UserPreferenceService>(),
            di<IAuthUserService>(),
            steps: steps,
            initialAnswers: initialAnswers,
          ),
        ),
        BlocProvider(
          create: (_) => UserPreferenceUpdateBtnController(
            di<IAuthUserService>(),
            di<IUserPreferenceRepository>(),
            di<IUserRecipeService>(),
          ),
        ),
      ],
      child: Builder(
        builder: (context) {
          final appTexts = di<TranslationController>().currentLanguage;
          final quizzController = context.read<OnboardingQuizzController>();

          return BlocListener<
            UserPreferenceUpdateBtnController,
            UserPreferenceUpdateBtnState
          >(
            listener: (context, state) {
              if (state is UserPreferenceUpdateBtnSuccess) {
                showSnackBar(context, appTexts.updateUserPreferenceSuccess);
                context.read<HomeScreenController>().reload();
              } else if (state is HasNotChangedUserPreference) {
                showSnackBar(context, appTexts.noChangeInUserPreference);
              }
            },
            child: BlocBuilder<OnboardingQuizzController, OnboardingQuizzState>(
              builder: (context, quizzState) {
                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final step in quizzController.steps) ...[
                              if (step != quizzController.steps.first)
                                const SizedBox(height: 28),
                              _SectionHeader(
                                title: step.title.text,
                                helper: step.helper.text,
                              ),
                              const SizedBox(height: 14),
                              _SectionContent(
                                step: step,
                                answers: quizzState.answers,
                                controller: quizzController,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 26),
                      child:
                          BlocBuilder<
                            UserPreferenceUpdateBtnController,
                            UserPreferenceUpdateBtnState
                          >(
                            builder: (context, state) {
                              return OnboardingPrimaryButton(
                                label: appTexts.update,
                                isLoading:
                                    state is UserPreferenceUpdateBtnLoading,
                                onPressed: () => context
                                    .read<UserPreferenceUpdateBtnController>()
                                    .update(
                                      buildUserPreferenceFrom(
                                        quizzState.answers,
                                        steps: quizzController.steps,
                                      ),
                                      DateTime.now(),
                                    ),
                              );
                            },
                          ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.helper});

  final String title;
  final String helper;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: robotoSlabFontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: recipeLoaderInkColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          helper,
          style: const TextStyle(
            fontFamily: robotoFontFamily,
            fontWeight: FontWeight.w400,
            fontSize: 12,
            height: 1.45,
            color: onboardingHelperTextColor,
          ),
        ),
      ],
    );
  }
}

class _SectionContent extends StatelessWidget {
  const _SectionContent({
    required this.step,
    required this.answers,
    required this.controller,
  });

  final OnboardingStep step;
  final OnboardingAnswers answers;
  final OnboardingQuizzController controller;

  @override
  Widget build(BuildContext context) {
    switch (step.kind) {
      case OnboardingStepKind.morphology:
        return MorphologyStep(
          answers: answers,
          onGenderChanged: controller.setGender,
          onHeightChanged: controller.setHeight,
          onWeightChanged: controller.setWeight,
        );
      case OnboardingStepKind.options:
        return OptionListStep(
          step: step,
          answers: answers,
          onToggle: (optionKey) => controller.toggleOption(step.key, optionKey),
          onTextChanged: controller.setText,
        );
      case OnboardingStepKind.chips:
        return ChipsStep(
          step: step,
          answers: answers,
          onToggle: (optionKey) => controller.toggleOption(step.key, optionKey),
          onTextChanged: controller.setText,
        );
    }
  }
}
