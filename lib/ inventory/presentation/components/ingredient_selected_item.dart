import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class IngredientSelectedItem extends StatelessWidget {
  const IngredientSelectedItem(
      {super.key,
      required this.isSelected,
      required this.ingredient,
      required this.onTap});
  final bool isSelected;
  final Ingredient ingredient;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100.w,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11.5),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            color: isSelected ? Color(0xFFFFCE80) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border:
                isSelected ? null : Border.all(color: const Color(0xFFFFBA4D))),
        child: Text(
          ingredient.name,
          style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
              fontSize: 11),
        ),
      ),
    );
  }
}
