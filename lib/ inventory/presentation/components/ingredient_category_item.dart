import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';

class IngredientCategoryItem extends StatelessWidget {
  const IngredientCategoryItem(
      {super.key,
    
      required this.onTap,
      required this.ingredient});
  final Ingredient ingredient;

  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11.5),
        // margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            color:
                Colors.white.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(10),
            border:
                Border.all(color: const Color(0xFFFFBA4D))),
        child: Text(
          ingredient.name,
          style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight:  FontWeight.w400,
              fontSize: 11),
        ),
      ),
    );
  }
}
