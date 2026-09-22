import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/kitchen/presentation/kitchen_inventory_screen.dart';
import 'package:recipe_ai/receipe/application/user_recipe_service.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/receipe/presentation/recipe_card.dart';
import 'package:recipe_ai/saved_receipe/presentation/saved_receipe_controller.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/user_preferences/presentation/components/custom_progress.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/functions.dart';
import 'package:recipe_ai/utils/widgets/empty_state_view.dart';

import '../../utils/styles.dart';

class NewSavedRecipeScreen extends StatelessWidget {
  const NewSavedRecipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final translationController = di<TranslationController>();

    return ListenableBuilder(
      listenable: translationController,
      builder: (context, _) => Scaffold(
        appBar: KitchenInventoryAppBar(
          arrowLeftOnPressed: () => context.pop(),
          title: translationController.currentLanguage.myFavorites,
        ),
        body: SavedReceipeScreen(),
      ),
    );
  }
}

class SavedReceipeScreen extends StatelessWidget {
  const SavedReceipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = bottomInsetForContentHiddenByTheNavBar(context);

    return BlocProvider(
      create: (context) => SavedReceipeController(di<IUserRecipeService>()),
      child: Builder(
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BlocBuilder<SavedReceipeController, SavedReceipeState>(
              builder: (context, state) {
                if (state is SavedReceipeStateLoading) {
                  return const Center(child: CustomProgress());
                }

                if (state is SavedReceipeStateError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: descriptionPlaceHolderStyle,
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (state is SavedReceipeStateLoaded) {
                  return state.savedReceipes.isEmpty
                      ? Column(
                          children: [
                            SizedBox(height: 70),
                            const NoFavoriteRecipeSaved(),
                          ],
                        )
                      : _SavedRecipesGridview(state.savedReceipes);
                }

                return SizedBox(height: bottomInset);
              },
            ),
          );
        },
      ),
    );
  }
}

class _SavedRecipesGridview extends StatelessWidget {
  const _SavedRecipesGridview(this._recipes);

  final List<UserRecipeV2> _recipes;

  @override
  Widget build(BuildContext context) {
    final translationController = di<TranslationController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_recipes.length.toString().padLeft(2, '0')} ${translationController.currentLanguage.savedRecipes}',
          style: TextStyle(
            fontFamily: robotoFontFamily,
            fontSize: 12.5,
            color: recipeLoaderInkColor.withValues(alpha: 0.55),
          ),
        ),
        const Gap(12.0),
        Expanded(
          child: GridView.builder(
            itemCount: _recipes.length,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemBuilder: (context, index) =>
                RecipeCard(receipe: _recipes[index], titleRecipeSize: 12.5),
          ),
        ),
      ],
    );
  }
}

class NoFavoriteRecipeSaved extends StatelessWidget {
  const NoFavoriteRecipeSaved({super.key});

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return EmptyStateView(
      icon: SvgPicture.asset(
        'assets/images/favorite_outlined.svg',
        width: 34,
        colorFilter: ColorFilter.mode(
          recipeLoaderInkColor.withValues(alpha: 0.45),
          BlendMode.srcIn,
        ),
      ),
      title: appTexts.noFavoriteRecipeTitle,
      subtitle: appTexts.noFavoriteRecipeSubtitle,
    );
  }
}
