import 'package:flutter/material.dart';
import 'package:recipe_ai/shopping/domain/model/inventory_item.dart';
import 'package:recipe_ai/shopping/domain/model/item_status.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

class InventoryItemCard extends StatelessWidget {
  const InventoryItemCard({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onSendToShoppingList,
  });

  final InventoryItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onSendToShoppingList;

  Color get _statusColor {
    switch (item.status) {
      case ItemStatus.ok:
        return greenPrimaryColor;
      case ItemStatus.lowStock:
        return orangeVariantColor;
      case ItemStatus.outOfStock:
        return Colors.red;
    }
  }

  String get _statusLabel {
    switch (item.status) {
      case ItemStatus.ok:
        return '';
      case ItemStatus.lowStock:
        return 'Stock bas';
      case ItemStatus.outOfStock:
        return 'Epuise';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
          //   blurRadius: 8,
          //   offset: const Offset(0, 2),
          // ),
        ],
      ),
      child: Row(
        children: [
          // Circular item image/emoji
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF5F0E8),
            ),
            child: Center(
              child: Text(
                item.emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name + status badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontFamily: poppinsFontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: neutralBlackColor,
                  ),
                ),
                if (_statusLabel.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      _statusLabel,
                      style: TextStyle(
                        fontFamily: poppinsFontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _statusColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Green circle - button
          _CircleButton(
            icon: Icons.remove,
            onTap: onDecrement,
          ),
          const SizedBox(width: 8),
          // Quantity
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
          // Green circle + button
          _CircleButton(
            icon: Icons.add,
           
            onTap: onIncrement,
          ),
          const SizedBox(width: 16),
          // Cart icon
          GestureDetector(
            onTap: onSendToShoppingList,
            child: Icon(
              Icons.shopping_cart_outlined,
              color: neutralGreyColor,
              size: 22,
            ),
          ),
        ],
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
