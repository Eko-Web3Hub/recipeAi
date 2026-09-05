import 'package:flutter/material.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

class ShoppingProgressBar extends StatelessWidget {
  const ShoppingProgressBar({
    super.key,
    required this.checked,
    required this.total,
    required this.progress,
    this.isStoreMode = false,
  });

  final int checked;
  final int total;
  final double progress;
  final bool isStoreMode;

  @override
  Widget build(BuildContext context) {
    final barHeight = isStoreMode ? 10.0 : 6.0;
    final allDone = total > 0 && checked == total;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalScreenPadding),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                allDone ? 'Tout est fait !' : '$checked sur $total',
                style: TextStyle(
                  fontFamily: poppinsFontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: allDone ? greenPrimaryColor : neutralBlackColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(barHeight / 2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.ease,
              height: barHeight,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: greyVariantColor.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(greenPrimaryColor),
                minHeight: barHeight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
