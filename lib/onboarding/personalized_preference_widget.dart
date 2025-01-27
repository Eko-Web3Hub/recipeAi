import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/utils/app_text.dart';
import 'package:recipe_ai/utils/colors.dart';

class PersonalizedPreferenceWidget extends StatelessWidget {
  const PersonalizedPreferenceWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Gap(56),
        const Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: EdgeInsets.only(right: 7),
            child: _InstructionWidget(
              AppText.frenchFood,
              27,
              BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),
        ),
        const Gap(100),
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 7),
            child: _InstructionWidget(
              '15mn',
              17,
              const BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(50),
                bottomLeft: Radius.circular(40),
              ),
              icon: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: SvgPicture.asset(
                  'assets/images/timerIcon.svg',
                ),
              ),
            ),
          ),
        ),
        const Gap(26),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 7.0,
            ),
            child: _InstructionWidget(
              '10 ingredients',
              16,
              const BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              icon: Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: SvgPicture.asset(
                  'assets/images/carrot.svg',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InstructionWidget extends StatelessWidget {
  const _InstructionWidget(
    this.label,
    this.horizontalPadding,
    this.borderRadius, {
    this.icon,
  });

  final String label;
  final double horizontalPadding;
  final BorderRadiusGeometry? borderRadius;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: orangeVariantColor,
        borderRadius: borderRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) icon!,
          Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              height: 24 / 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
