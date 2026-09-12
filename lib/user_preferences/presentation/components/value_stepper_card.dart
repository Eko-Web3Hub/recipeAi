import 'package:flutter/material.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

/// Height / weight card: label, big value with its unit, and the two round
/// steppers underneath.
class ValueStepperCard extends StatelessWidget {
  const ValueStepperCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.onChanged,
    this.min = 0,
    this.max = 999,
  });

  final String label;
  final int value;
  final String unit;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: onboardingOptionBorderColor),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontFamily: robotoFontFamily,
              fontWeight: FontWeight.w500,
              fontSize: 10.5,
              letterSpacing: 0.6,
              color: onboardingSubtleTextColor,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$value',
                style: const TextStyle(
                  fontFamily: robotoSlabFontFamily,
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                  color: recipeLoaderInkColor,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                unit,
                style: const TextStyle(
                  fontFamily: robotoFontFamily,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: onboardingSubtleTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StepperButton(
                icon: Icons.remove,
                background: recipeLoaderInkColor.withValues(alpha: 0.06),
                foreground: recipeLoaderInkColor,
                onTap: value > min ? () => onChanged(value - 1) : null,
              ),
              const SizedBox(width: 12),
              _StepperButton(
                icon: Icons.add,
                background: recipeLoaderMintColor,
                foreground: recipeLoaderGreenColor,
                onTap: value < max ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(
            icon,
            size: 18,
            color: onTap == null
                ? foreground.withValues(alpha: 0.4)
                : foreground,
          ),
        ),
      ),
    );
  }
}
