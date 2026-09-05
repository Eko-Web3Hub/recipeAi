import 'package:flutter/material.dart';
import 'package:recipe_ai/shopping/domain/model/shopping_item.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

class ShoppingItemCard extends StatelessWidget {
  const ShoppingItemCard({
    super.key,
    required this.item,
    required this.isStoreMode,
    required this.onToggleChecked,
    required this.onIncrement,
    required this.onDecrement,
  });

  final ShoppingItem item;
  final bool isStoreMode;
  final VoidCallback onToggleChecked;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final checkboxSize =  26.0;
    final textSize =  15.0;
    final opacity = item.isChecked ? 0.5 : 1.0;

    return GestureDetector(
      onTap: onToggleChecked,
      child: Opacity(
        opacity: opacity,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical:  10,
          ),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [

               BoxShadow(
           color: Color.fromRGBO(6, 51, 54, 0.1),
           offset: Offset(0, 2),
           blurRadius: 16,
           spreadRadius: 0,
          )
              // BoxShadow(
              //   color: Colors.black.withValues(alpha: 0.04),
              //   blurRadius: 6,
              //   offset: const Offset(0, 2),
              // ),
            ],
          ),
          child: Row(
            children: [
              // Checkbox
              _Checkbox(
                size: checkboxSize,
                isChecked: item.isChecked,
                onTap: onToggleChecked,
              ),
              const SizedBox(width: 12),
              // Circular item image/emoji
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF5F0E8),
                ),
                child: Center(
                  child: Text(
                    item.emoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Name + unit
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontFamily: poppinsFontFamily,
                        fontSize: textSize,
                        fontWeight: FontWeight.w600,
                        color: neutralBlackColor,
                        decoration: item.isChecked
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    Text(
                      '${item.quantity} ${item.unit}',
                      style: TextStyle(
                        fontFamily: poppinsFontFamily,
                        fontSize: 12,
                        color: neutralGreyColor,
                      ),
                    ),
                  ],
                ),
              ),
              // Quantity buttons (hidden in store mode)
              if (!isStoreMode) ...[
                _CircleButton(
                  icon: Icons.remove,
                  onTap: onDecrement,
                ),
                const SizedBox(width: 8),
                Text(
                  '${item.quantity}',
                  style: TextStyle(
                    fontFamily: poppinsFontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: neutralBlackColor,
                  ),
                ),
                const SizedBox(width: 8),
                _CircleButton(
                  icon: Icons.add,
                 // filled: true,
                  onTap: onIncrement,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Checkbox extends StatelessWidget {
  const _Checkbox({
    required this.size,
    required this.isChecked,
    required this.onTap,
  });

  final double size;
  final bool isChecked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isChecked ? greenPrimaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isChecked ? greenPrimaryColor : greyVariantColor,
            width: 2,
          ),
        ),
        child: isChecked
            ? Icon(
                Icons.check,
                size: size * 0.6,
                color: Colors.white,
              )
            : null,
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: filled ? greenPrimaryColor : Colors.transparent,
          border: Border.all(
            color: greenPrimaryColor,
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: filled ? Colors.white : greenPrimaryColor,
        ),
      ),
    );
  }
}
