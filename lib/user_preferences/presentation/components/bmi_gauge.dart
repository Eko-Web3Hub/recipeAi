import 'package:flutter/material.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/user_preferences/domain/model/onboarding_answers.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

/// Cream card showing the computed BMI, its label and where it sits on the
/// underweight → obesity scale.
class BmiGauge extends StatelessWidget {
  const BmiGauge({super.key, required this.bmi, required this.category});

  final double bmi;
  final BmiCategory category;

  /// Bounds of the drawn scale; the segments below split it at 18.5 / 25 / 30.
  static const _minBmi = 15.0;
  static const _maxBmi = 40.0;

  static const _segments = <(double, Color)>[
    (18.5 - _minBmi, bmiUnderweightColor),
    (25 - 18.5, bmiNormalColor),
    (30 - 25, bmiOverweightColor),
    (_maxBmi - 30, bmiObesityColor),
  ];

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;
    final labels = [
      appTexts.bmiUnderweight,
      appTexts.bmiNormal,
      appTexts.bmiOverweight,
      appTexts.bmiObesity,
    ];
    final status = switch (category) {
      BmiCategory.underweight => appTexts.bmiStatusUnderweight,
      BmiCategory.normal => appTexts.bmiStatusNormal,
      BmiCategory.overweight => appTexts.bmiStatusOverweight,
      BmiCategory.obesity => appTexts.bmiStatusObesity,
    };
    final ratio = ((bmi - _minBmi) / (_maxBmi - _minBmi)).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: recipeLoaderCreamColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appTexts.bmiLabel.toUpperCase(),
            style: const TextStyle(
              fontFamily: robotoFontFamily,
              fontWeight: FontWeight.w500,
              fontSize: 10.5,
              letterSpacing: 0.6,
              color: onboardingSubtleTextColor,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                bmi.toStringAsFixed(1).replaceAll('.', ','),
                style: const TextStyle(
                  fontFamily: robotoSlabFontFamily,
                  fontWeight: FontWeight.w700,
                  fontSize: 26,
                  color: recipeLoaderInkColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  status,
                  style: const TextStyle(
                    fontFamily: robotoFontFamily,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                    color: recipeLoaderGreenColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              const knobSize = 16.0;
              final trackWidth = constraints.maxWidth;

              return SizedBox(
                height: knobSize,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.centerLeft,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Row(
                        children: [
                          for (final (weight, color) in _segments)
                            Expanded(
                              flex: (weight * 10).round(),
                              child: SizedBox(
                                height: 6,
                                child: ColoredBox(color: color),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: (trackWidth - knobSize) * ratio,
                      child: Container(
                        width: knobSize,
                        height: knobSize,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: recipeLoaderInkColor,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var index = 0; index < _segments.length; index++)
                Expanded(
                  flex: (_segments[index].$1 * 10).round(),
                  child: Text(
                    labels[index],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: robotoFontFamily,
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                      color: onboardingSubtleTextColor,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
