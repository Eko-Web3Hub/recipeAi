import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/constant.dart';

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
    final appLanguage = di<TranslationController>().currentLanguageEnum;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11.5),
        //  margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            color: isSelected ? Color(0xFFFFCE80) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border:
                isSelected ? null : Border.all(color: const Color(0xFFFFBA4D))),
        child: Text(
          appLanguage == AppLanguage.fr
              ? ingredient.nameFr ?? ingredient.name
              : ingredient.name,
          style: GoogleFonts.poppins(
              color: Colors.black, fontWeight: FontWeight.w400, fontSize: 11),
        ),
      ),
    );
  }
}
