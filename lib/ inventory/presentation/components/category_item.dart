import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/%20inventory/domain/model/category.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/constant.dart';

class CategoryItem extends StatelessWidget {
  const CategoryItem(
      {super.key,
      required this.isSelected,
      required this.onTap,
      required this.category});
  final bool isSelected;
  final Category category;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    final appLanguage = di<TranslationController>().currentLanguageEnum;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
        decoration: isSelected
            ? BoxDecoration(
                color: const Color(0xFFFFCE80).withValues(alpha: 0.4),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                border: Border(
                    bottom:
                        BorderSide(color: const Color(0xFFFFCE80), width: 2)))
            : null,
        child: Center(
          child: Text(
            appLanguage == AppLanguage.fr ? category.nameFr : category.name,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
