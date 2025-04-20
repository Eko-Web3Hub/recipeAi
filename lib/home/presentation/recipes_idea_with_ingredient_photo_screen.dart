import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/home/presentation/home_screen.dart';
import 'package:recipe_ai/kitchen/presentation/kitchen_inventory_screen.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/constant.dart';

class RecipesIdeaWithIngredientPhotoScreen extends StatelessWidget {
  const RecipesIdeaWithIngredientPhotoScreen({
    super.key,
    required this.recipes,
  });

  final List<UserReceipeV2> recipes;

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return Scaffold(
      appBar: KitchenInventoryAppBar(
        title: appTexts.receipeIdeas,
        arrowLeftOnPressed: () => context.go(
          '/home',
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalScreenPadding,
        ),
        child: Column(
          children: recipes
              .map<Widget>((userRecipe) => ReceipeItem(
                    key: ValueKey(userRecipe.id),
                    redirectionPath: '/recipe-details',
                    receipe: userRecipe,
                  ))
              .toList(),
        ),
      ),
    );
  }
}
