import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:recipe_ai/utils/colors.dart';

class OnboardingFirstSectionWidget extends StatelessWidget {
  const OnboardingFirstSectionWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 28.0,
              ),
              child: _IconWidget(
                'assets/images/camera_add.svg',
                Theme.of(context).primaryColor,
              ),
            ),
            const Gap(35),
            Container(
              width: 172,
              height: 168,
              decoration: BoxDecoration(
                color: greyVariantColor,
                borderRadius: BorderRadius.circular(
                  20,
                ),
                image: const DecorationImage(
                  image: AssetImage(
                    'assets/images/onboardingFirstImage.png',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
        const Gap(5.0),
        Column(
          children: [
            Container(
              width: 137,
              height: 137,
              decoration: BoxDecoration(
                color: greyVariantColor,
                borderRadius: BorderRadius.circular(
                  20,
                ),
                image: const DecorationImage(
                  image: AssetImage(
                    'assets/images/onboardingSecondImage.jpeg',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const Gap(37),
            const Center(
              child: _IconWidget(
                'assets/images/mingcute-ai-fill.svg',
                orangeVariantColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _IconWidget extends StatelessWidget {
  const _IconWidget(
    this.icon,
    this.bgColor,
  );

  final String icon;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(
          20,
        ),
      ),
      child: Center(
        child: SvgPicture.asset(
          icon,
          fit: BoxFit.contain,
          width: 24,
          height: 24,
        ),
      ),
    );
  }
}
