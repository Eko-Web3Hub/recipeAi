import 'package:flutter/material.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/user_preferences/domain/model/onboarding_answers.dart';
import 'package:recipe_ai/user_preferences/presentation/components/bmi_gauge.dart';
import 'package:recipe_ai/user_preferences/presentation/components/gender_segmented_control.dart';
import 'package:recipe_ai/user_preferences/presentation/components/value_stepper_card.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

/// "Parle-nous de toi": gender, height, weight and the live BMI card.
class MorphologyStep extends StatelessWidget {
  const MorphologyStep({
    super.key,
    required this.answers,
    required this.onGenderChanged,
    required this.onHeightChanged,
    required this.onWeightChanged,
  });

  final OnboardingAnswers answers;
  final ValueChanged<UserGender> onGenderChanged;
  final ValueChanged<int> onHeightChanged;
  final ValueChanged<int> onWeightChanged;

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          appTexts.morphologyGender.toUpperCase(),
          style: const TextStyle(
            fontFamily: robotoFontFamily,
            fontWeight: FontWeight.w500,
            fontSize: 10.5,
            letterSpacing: 0.6,
            color: onboardingSubtleTextColor,
          ),
        ),
        const SizedBox(height: 8),
        GenderSegmentedControl(
          value: answers.gender,
          onChanged: onGenderChanged,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: ValueStepperCard(
                label: appTexts.morphologyHeight,
                value: answers.heightCm,
                unit: appTexts.unitCentimeter,
                min: OnboardingAnswers.minHeightCm,
                max: OnboardingAnswers.maxHeightCm,
                onChanged: onHeightChanged,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ValueStepperCard(
                label: appTexts.morphologyWeight,
                value: answers.weightKg,
                unit: appTexts.unitKilogram,
                min: OnboardingAnswers.minWeightKg,
                max: OnboardingAnswers.maxWeightKg,
                onChanged: onWeightChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        BmiGauge(bmi: answers.bmi, category: answers.bmiCategory),
      ],
    );
  }
}
