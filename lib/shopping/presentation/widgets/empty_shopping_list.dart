import 'package:flutter/material.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

class EmptyShoppingList extends StatelessWidget {
  const EmptyShoppingList({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '\u{1F6D2}',
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              'Liste vide',
              style: TextStyle(
                fontFamily: poppinsFontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: neutralBlackColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez des articles avec le champ\nci-dessus ou depuis l\'inventaire.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: poppinsFontFamily,
                fontSize: 13,
                color: neutralGreyColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
