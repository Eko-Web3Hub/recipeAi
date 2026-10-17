import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/l10n/app_localizations.dart';
import 'package:recipe_ai/receipe/domain/model/recipe_source.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/functions.dart';

/// Card showing where a recipe comes from, on the recipe details screen.
class RecipeSourceCard extends StatelessWidget {
  const RecipeSourceCard({super.key, required this.source});

  final RecipeSource source;

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;
    final isLink = source.type == RecipeSourceType.link;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: recipeLoaderMintColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.link, size: 18.0, color: recipeLoaderGreenColor),
          const Gap(12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appTexts.recipeDetailsSourceTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.0,
                    fontFamily: poppinsFontFamily,
                    color: recipeLoaderGreenColor,
                  ),
                ),
                const Gap(3.0),
                GestureDetector(
                  onTap: isLink ? () => launchUrlFunc(source.value) : null,
                  child: Text(
                    _label(appTexts, source),
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontFamily: poppinsFontFamily,
                      fontSize: 12.0,
                      height: 1.5,
                      color: recipeLoaderInkColor,
                      decoration: isLink ? TextDecoration.underline : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _label(AppLocalizations appTexts, RecipeSource source) {
    switch (source.type) {
      case RecipeSourceType.author:
        return appTexts.recipeDetailsSourceAuthor(source.value);
      case RecipeSourceType.link:
      case RecipeSourceType.other:
        return source.value;
    }
  }
}
