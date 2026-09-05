import 'package:flutter/material.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

class QuantitySelector extends StatelessWidget {
  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.unit,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final String unit;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RoundButton(
          icon: Icons.remove,
          onTap: onDecrement,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '$quantity',
            style: TextStyle(
              fontFamily: poppinsFontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: neutralBlackColor,
            ),
          ),
        ),
        _RoundButton(
          icon: Icons.add,
          onTap: onIncrement,
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: greyVariantColor),
        ),
        child: Icon(
          icon,
          size: 16,
          color: neutralBlackColor,
        ),
      ),
    );
  }
}
