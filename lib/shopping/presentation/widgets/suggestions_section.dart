import 'package:flutter/material.dart';
import 'package:recipe_ai/shopping/domain/model/shopping_item.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

class SuggestionsSection extends StatelessWidget {
  const SuggestionsSection({
    super.key,
    required this.suggestions,
    required this.onAdd,
  });

  final List<ShoppingItem> suggestions;
  final ValueChanged<String> onAdd;

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          'SUGGESTIONS - ACHETES FREQUEMMENT',
          style: TextStyle(
            fontFamily: poppinsFontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: neutralGreyColor,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions.map((item) {
            return GestureDetector(
              onTap: () => onAdd(item.id),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: greyVariantColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(item.emoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      item.name,
                      style: TextStyle(
                        fontFamily: poppinsFontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: neutralBlackColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.add, size: 16, color: greenPrimaryColor),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
