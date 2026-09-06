import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

const _kdotContentFoodFactBackgroundColor = Color(0xffa5761f);

class FoodFactCard extends StatelessWidget {
  const FoodFactCard({super.key, required this.foodFact});
  final String foodFact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: foodFactCardBackgroundColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ContentFoodFactDot(),
          const Gap(12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Le savais-tu ?',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.0,
                    fontFamily: poppinsFontFamily,
                    color: _kdotContentFoodFactBackgroundColor,
                  ),
                ),
                const Gap(3.0),
                Text(
                  foodFact,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontFamily: poppinsFontFamily,
                    fontSize: 12.0,
                    height: 1.5,
                    color: foodFactCardTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentFoodFactDot extends StatelessWidget {
  const _ContentFoodFactDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20.0,
      height: 20.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _kdotContentFoodFactBackgroundColor,
      ),
    );
  }
}
