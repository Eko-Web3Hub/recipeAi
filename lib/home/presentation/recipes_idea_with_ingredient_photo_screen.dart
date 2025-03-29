import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/home/presentation/home_screen.dart';
import 'package:recipe_ai/home/presentation/recipes_idea_with_ingredient_photo_controller.dart';
import 'package:recipe_ai/kitchen/presentation/kitchen_inventory_screen.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/user_preferences/presentation/components/custom_circular_loader.dart';
import 'package:recipe_ai/utils/constant.dart';

class RecipesIdeaWithIngredientPhotoScreen extends StatelessWidget {
  const RecipesIdeaWithIngredientPhotoScreen({
    super.key,
    required this.recipes,
  });

  final TranslatedRecipe recipes;

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return BlocProvider(
      create: (context) => RecipesIdeaWithIngredientPhotoController(
        recipes,
        di<TranslationController>(),
      ),
      child: Scaffold(
        appBar: KitchenInventoryAppBar(
          title: appTexts.receipeIdeas,
          arrowLeftOnPressed: () => context.go(
            '/home',
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalScreenPadding,
            ),
            child: Column(
              children: [
                BlocBuilder<RecipesIdeaWithIngredientPhotoController,
                    List<Receipe>?>(
                  builder: (context, state) {
                    if (state == null) {
                      return const Center(
                        child: CustomCircularLoader(
                          size: 20,
                        ),
                      );
                    }
                    return Padding(
                      padding: EdgeInsets.only(
                        top: 15,
                        bottom: 20,
                      ),
                      child: Column(
                        children: state
                            .map<Widget>(
                              (recipe) => ReceipeItem(
                                redirectionPath: '/recipe-details',
                                key: ValueKey(recipe.name),
                                receipe: recipe,
                                isSaved: false,
                                onTap: () {},
                              ),
                            )
                            .toList(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
