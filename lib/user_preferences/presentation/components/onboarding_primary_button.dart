import 'package:flutter/material.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

/// Green CTA of the onboarding: 52px tall, 15px radius (mockup `.mprimary`).
class OnboardingPrimaryButton extends StatelessWidget {
  const OnboardingPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.background = recipeLoaderGreenColor,
    this.foreground = Colors.white,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(15);

    return Material(
      color: onPressed == null ? background.withValues(alpha: 0.5) : background,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        child: SizedBox(
          height: 52,
          width: double.infinity,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation(foreground),
                    ),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      fontFamily: robotoFontFamily,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: foreground,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
