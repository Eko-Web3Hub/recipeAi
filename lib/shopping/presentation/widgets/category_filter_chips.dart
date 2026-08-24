import 'package:flutter/material.dart';
import 'package:recipe_ai/shopping/domain/model/item_category.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

class CategoryFilterChips extends StatelessWidget {
  const CategoryFilterChips({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelect,
  });

  final List<ItemCategory> categories;
  final String? selectedCategoryId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: horizontalScreenPadding),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category.id == selectedCategoryId;

          // "Tout" gets dark style, others get green
          final isAllChip = category.id == 'all';
          final activeColor =
              isAllChip ? newNeutralBlackColor : newNeutralBlackColor;

          return GestureDetector(
            onTap: () => onSelect(category.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? activeColor : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? activeColor : greyVariantColor,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  category.name,
                  style: TextStyle(
                    fontFamily: poppinsFontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : neutralBlackColor,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
