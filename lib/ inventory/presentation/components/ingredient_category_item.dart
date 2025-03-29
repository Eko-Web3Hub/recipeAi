import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';

class IngredientCategoryItem extends StatelessWidget {
  const IngredientCategoryItem(
      {super.key,
      required this.isSelected,
      required this.onTap,
      required this.ingredient});
  final bool isSelected;
  final Ingredient ingredient;

  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            color: isSelected ? Color(0xFFFFCE80) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border:
                isSelected ? null : Border.all(color: const Color(0xFFFFBA4D))),
        child: Center(
          child: Row(
            children: [
              Text(
                ingredient.name,
                style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
                    fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
