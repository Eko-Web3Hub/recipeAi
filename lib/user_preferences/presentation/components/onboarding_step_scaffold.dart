import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:recipe_ai/user_preferences/presentation/components/onboarding_progress_bar.dart';
import 'package:recipe_ai/user_preferences/presentation/components/onboarding_primary_button.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

/// Common frame of every quizz step: progress, question, scrollable content and
/// the sticky CTA over a white gradient.
class OnboardingStepScaffold extends StatelessWidget {
  const OnboardingStepScaffold({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.title,
    required this.helper,
    required this.ctaLabel,
    required this.onCta,
    required this.child,
    this.onBack,
    this.isLoading = false,
    this.footnote,
  });

  /// 1 based.
  final int currentStep;
  final int totalSteps;
  final String title;
  final String helper;
  final String ctaLabel;
  final VoidCallback? onCta;
  final Widget child;

  /// Not in the mockups, but a 5 step flow needs a way back on iOS.
  final VoidCallback? onBack;
  final bool isLoading;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 36,
                child: onBack == null
                    ? null
                    : Align(
                        alignment: Alignment.centerLeft,
                        child: _BackButton(onTap: onBack!),
                      ),
              ),
              const SizedBox(height: 8),
              OnboardingProgressBar(
                currentStep: currentStep,
                totalSteps: totalSteps,
              ),
              const SizedBox(height: 22),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: robotoSlabFontFamily,
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                  height: 1.25,
                  color: recipeLoaderInkColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                helper,
                style: const TextStyle(
                  fontFamily: robotoFontFamily,
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                  height: 1.5,
                  color: onboardingHelperTextColor,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 8),
            child: child,
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 26),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              stops: [0.62, 1],
              colors: [Colors.white, Color(0x00FFFFFF)],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (footnote != null) ...[
                Text(
                  footnote!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: robotoFontFamily,
                    fontWeight: FontWeight.w400,
                    fontSize: 11,
                    height: 1.45,
                    color: onboardingSubtleTextColor,
                  ),
                ),
                const SizedBox(height: 14),
              ],
              OnboardingPrimaryButton(
                label: ctaLabel,
                onPressed: onCta,
                isLoading: isLoading,
              ),
              const Gap(50),
            ],
          ),
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: recipeLoaderInkColor.withValues(alpha: 0.06),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.chevron_left,
          size: 22,
          color: recipeLoaderInkColor,
        ),
      ),
    );
  }
}
