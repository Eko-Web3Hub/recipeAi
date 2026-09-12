import 'package:flutter/material.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

/// Segmented progress of the onboarding: one segment per step, plus the "2/5"
/// counter on the right. The number of segments follows the number of steps.
class OnboardingProgressBar extends StatelessWidget {
  const OnboardingProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  /// 1 based.
  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              for (var index = 0; index < totalSteps; index++) ...[
                if (index > 0) const SizedBox(width: 6),
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    height: 4,
                    decoration: BoxDecoration(
                      color: index < currentStep
                          ? recipeLoaderGreenColor
                          : onboardingProgressTrackColor,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          appTexts.onboardingStepCounter(currentStep, totalSteps),
          style: const TextStyle(
            fontFamily: robotoFontFamily,
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: onboardingSubtleTextColor,
          ),
        ),
      ],
    );
  }
}
