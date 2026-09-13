import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/receipe/domain/model/user_finished_recipe.dart';
import 'package:recipe_ai/receipe/presentation/receipe_details_view.dart';
import 'package:recipe_ai/receipe/presentation/recipe_cook/recipe_cook_ship_controller.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/colors.dart';

class RecipeCookShip extends StatelessWidget {
  const RecipeCookShip({
    super.key,
    this.neededLeftSpace = false,
    required this.recipeId,
  });

  final EntityId recipeId;
  final bool neededLeftSpace;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RecipeCookShipController>(
      create: (context) => RecipeCookShipController.inject(recipeId: recipeId),
      child: BlocBuilder<RecipeCookShipController, RecipeCookedSummary?>(
        builder: (context, summary) {
          final recipeCount = summary?.count ?? 0;

          return recipeCount == 0
              ? SizedBox.shrink()
              : Padding(
                  padding: EdgeInsets.only(left: neededLeftSpace ? 6.0 : 0.0),
                  child: _RecipeCookLayout(recipeCount: recipeCount),
                );
        },
      ),
    );
  }
}

class _RecipeCookLayout extends StatelessWidget {
  const _RecipeCookLayout({required this.recipeCount});

  final int recipeCount;

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return TagChip(
      label: appTexts.recipeCookedCount(recipeCount),
      foregroundColor: Colors.white,
      backgroundColor: cookedRecipeShigBgColor,
    );
  }
}
