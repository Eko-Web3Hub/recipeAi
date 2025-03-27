import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/home/presentation/home_screen.dart';
import 'package:recipe_ai/kitchen/presentation/kitchen_inventory_screen.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';

class RecipesIdeaWithIngredientPhotoScreen extends StatelessWidget {
  const RecipesIdeaWithIngredientPhotoScreen({
    super.key,
    required this.recipes,
  });

  final List<Receipe> recipes;

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return SafeArea(
      child: Scaffold(
        appBar: KitchenInventoryAppBar(
          title: appTexts.receipeIdeas,
          arrowLeftOnPressed: () => context.go(
            '/home',
          ),
        ),
        body: Column(
          children: [
            ...recipes.map<Widget>(
              (recipe) => ReceipeItem(
                receipe: recipe,
                isSaved: false,
                onTap: () {},
              ),
            )
          ],
        ),
      ),
    );
  }
}
