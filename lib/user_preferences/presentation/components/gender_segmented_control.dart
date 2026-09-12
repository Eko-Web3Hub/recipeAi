import 'package:flutter/material.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/user_preferences/domain/model/onboarding_answers.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

/// Femme / Homme / Autre, three equal pills.
class GenderSegmentedControl extends StatelessWidget {
  const GenderSegmentedControl({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final UserGender? value;
  final ValueChanged<UserGender> onChanged;

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;
    final labels = {
      UserGender.female: appTexts.genderFemale,
      UserGender.male: appTexts.genderMale,
      UserGender.other: appTexts.genderOther,
    };

    return Row(
      children: [
        for (final gender in UserGender.values) ...[
          if (gender != UserGender.values.first) const SizedBox(width: 10),
          Expanded(
            child: _GenderPill(
              label: labels[gender]!,
              selected: value == gender,
              onTap: () => onChanged(gender),
            ),
          ),
        ],
      ],
    );
  }
}

class _GenderPill extends StatelessWidget {
  const _GenderPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? recipeLoaderMintColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? recipeLoaderGreenColor
                : onboardingOptionBorderColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: robotoFontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
            color: selected ? recipeLoaderGreenColor : recipeLoaderInkColor,
          ),
        ),
      ),
    );
  }
}
