import 'package:flutter/material.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/user_preferences/presentation/onboarding_steps.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

/// One answer of the quizz. The three shapes of the mockups are covered by
/// [OptionTileStyle]: a big colored dot, a rounded icon tile, or a small dot
/// with a square checkbox.
class OnboardingOptionTile extends StatelessWidget {
  const OnboardingOptionTile({
    super.key,
    required this.option,
    required this.style,
    required this.selected,
    required this.showCheckbox,
    required this.onTap,
  });

  final OnboardingOption option;
  final OptionTileStyle style;
  final bool selected;
  final bool showCheckbox;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;
    final description = option.description?.call(appTexts);
    final borderRadius = BorderRadius.circular(14);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? recipeLoaderMintColor : Colors.white,
          borderRadius: borderRadius,
          border: Border.all(
            color: selected
                ? recipeLoaderGreenColor
                : onboardingOptionBorderColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            _leading(),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    option.label(appTexts),
                    style: const TextStyle(
                      fontFamily: robotoFontFamily,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                      color: recipeLoaderInkColor,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: const TextStyle(
                        fontFamily: robotoFontFamily,
                        fontWeight: FontWeight.w400,
                        fontSize: 11.5,
                        color: onboardingSubtleTextColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showCheckbox) ...[
              const SizedBox(width: 12),
              _Checkbox(
                selected: selected,
                square: style == OptionTileStyle.smallDot,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _leading() {
    switch (style) {
      case OptionTileStyle.colorDot:
        return Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: option.color ?? recipeLoaderGreenColor,
            shape: BoxShape.circle,
          ),
        );
      case OptionTileStyle.smallDot:
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: option.color ?? recipeLoaderGreenColor,
            shape: BoxShape.circle,
          ),
        );
      case OptionTileStyle.iconTile:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: selected ? recipeLoaderGreenColor : onboardingIconTileColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            option.icon,
            size: 21,
            color: selected ? Colors.white : recipeLoaderInkColor,
          ),
        );
    }
  }
}

class _Checkbox extends StatelessWidget {
  const _Checkbox({required this.selected, required this.square});

  final bool selected;
  final bool square;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: selected ? recipeLoaderGreenColor : Colors.transparent,
        shape: square ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: square ? BorderRadius.circular(6) : null,
        border: selected
            ? null
            : Border.all(color: onboardingCheckBorderColor, width: 1.5),
      ),
      child: selected
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : null,
    );
  }
}
