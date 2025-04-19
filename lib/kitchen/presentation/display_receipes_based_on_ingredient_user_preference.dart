import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/home/presentation/home_screen.dart';
import 'package:recipe_ai/home/presentation/receipe_item_controller.dart';
import 'package:recipe_ai/kitchen/application/retrieve_recipes_based_on_user_ingredient_and_preferences_usecase.dart';
import 'package:recipe_ai/kitchen/presentation/display_receipes_based_on_ingredient_user_preference_controller.dart';
import 'package:recipe_ai/kitchen/presentation/kitchen_inventory_screen.dart';

import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/user_preferences/presentation/components/custom_progress.dart';
import 'package:recipe_ai/utils/constant.dart';

class DisplayReceipesBasedOnIngredientUserPreferenceScreen
    extends StatelessWidget {
  const DisplayReceipesBasedOnIngredientUserPreferenceScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return BlocProvider(
      create: (context) =>
          DisplayReceipesBasedOnIngredientUserPreferenceController(
        di<IAuthUserService>(),
        di<RetrieveRecipesBasedOnUserIngredientAndPreferencesUsecase>(),
      ),
      child: Scaffold(
        appBar: KitchenInventoryAppBar(
          title: appTexts.receipeIdeas,
          arrowLeftOnPressed: () => context.go(
            '/home',
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: horizontalScreenPadding,
          ),
          child: Column(
            children: [
              BlocBuilder<
                  DisplayReceipesBasedOnIngredientUserPreferenceController,
                  DisplayReceipesBasedOnIngredientUserPreferenceState>(
                builder: (context, state) {
                  if (state
                      is DisplayReceipesBasedOnIngredientUserPreferenceLoading) {
                    return const _LoadingView();
                  }
                  final receipes = (state
                          as DisplayReceipesBasedOnIngredientUserPreferenceLoaded)
                      .receipes;

                  return Expanded(
                    child: _DisplayLoadedRecipe(
                      receipes: receipes,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return Center(
        child: Column(
      children: [
        const Gap(120),
        Text(
          appTexts.receipeIdeasDescription,
          style: Theme.of(context).textTheme.labelSmall!.copyWith(
                color: Colors.black,
              ),
          textAlign: TextAlign.center,
        ),
        const Gap(20),
        const CustomProgress(
          color: Colors.black,
        ),
      ],
    ));
  }
}

class _DisplayLoadedRecipe extends StatelessWidget {
  const _DisplayLoadedRecipe({
    required this.receipes,
  });

  final List<UserReceipeV2> receipes;

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return receipes.isEmpty
        ? Center(
            child: Text(
              appTexts.cannotGenerateReceipeIdeas,
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: Colors.black,
                  ),
              textAlign: TextAlign.center,
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.only(bottom: 20, top: 15),
            itemCount: receipes.length,
            itemBuilder: (context, index) =>
                BlocBuilder<ReceipeItemController, ReceipeItemState>(
              builder: (context, state) {
                return ReceipeItem(
                  receipe: receipes[index],
                  isSaved: state is ReceipeItemStateSaved,
                  redirectionPath: '/recipe-details',
                );
              },
            ),
          );
  }
}
