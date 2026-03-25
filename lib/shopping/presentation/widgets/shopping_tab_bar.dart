import 'package:flutter/material.dart';
import 'package:recipe_ai/shopping/presentation/shopping_state.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

class ShoppingTabBar extends StatelessWidget {
  const ShoppingTabBar({
    super.key,
    required this.activeTab,
    required this.onSwitch,
  });

  final ShoppingTab activeTab;
  final ValueChanged<ShoppingTab> onSwitch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: greenPrimaryColor, width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: _TabButton(
                label: 'Mon inventaire',
                isActive: activeTab == ShoppingTab.inventory,
                onTap: () => onSwitch(ShoppingTab.inventory),
              ),
            ),
            Expanded(
              child: _TabButton(
                label: 'Mes courses',
                isActive: activeTab == ShoppingTab.shoppingList,
                onTap: () => onSwitch(ShoppingTab.shoppingList),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? yellowBrandColor : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: poppinsFontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color:  neutralGrey2ColorNight,
            ),
          ),
        ),
      ),
    );
  }
}
