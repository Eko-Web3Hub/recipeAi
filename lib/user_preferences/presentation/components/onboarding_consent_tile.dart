import 'package:flutter/material.dart';
import 'package:recipe_ai/user_preferences/presentation/components/onboarding_option_tile.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

/// Consent of a step (health data), shown under its options once one is
/// picked: a square checkbox and its text.
class OnboardingConsentTile extends StatelessWidget {
  const OnboardingConsentTile({
    super.key,
    required this.label,
    required this.accepted,
    required this.onChanged,
  });

  final String label;
  final bool accepted;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: accepted,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!accepted),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OnboardingCheckbox(selected: accepted, square: true),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: robotoFontFamily,
                    fontWeight: FontWeight.w400,
                    fontSize: 12.5,
                    height: 1.35,
                    color: recipeLoaderInkColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
