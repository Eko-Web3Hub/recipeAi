import 'package:flutter/material.dart';
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
                '',
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
              ),
            ),
            const Gap(37),
            const Center(
              child: _IconWidget(
                '',
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
    );
  }
}
