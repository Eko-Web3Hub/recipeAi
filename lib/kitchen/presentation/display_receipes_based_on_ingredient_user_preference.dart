import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/home/presentation/home_screen.dart';
import 'package:recipe_ai/home/presentation/recipe_generation_loader.dart';

import 'package:recipe_ai/kitchen/application/retrieve_recipes_based_on_user_ingredient_and_preferences_usecase.dart';
import 'package:recipe_ai/kitchen/infrastructure/receipes_based_on_ingredient_user_preference_repository.dart';
import 'package:recipe_ai/kitchen/presentation/display_receipes_based_on_ingredient_user_preference_controller.dart';
import 'package:recipe_ai/kitchen/presentation/kitchen_inventory_screen.dart';

import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/user_preferences/presentation/components/onboarding_primary_button.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

class DisplayReceipesBasedOnIngredientUserPreferenceScreen
    extends StatelessWidget {
  const DisplayReceipesBasedOnIngredientUserPreferenceScreen({super.key});

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
          arrowLeftOnPressed: () => context.go('/home'),
        ),
        body: const Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalScreenPadding),
          child: _RecipeIdeasBody(),
        ),
      ),
    );
  }
}

/// Keeps the loader on screen for the whole generation: the "recipe ready"
/// scene only plays once the API answered with at least one recipe, and the
/// list only replaces it when that scene is over. Any other outcome — an empty
/// answer or an error — goes straight to a message, never to "ready".
class _RecipeIdeasBody extends StatefulWidget {
  const _RecipeIdeasBody();

  @override
  State<_RecipeIdeasBody> createState() => _RecipeIdeasBodyState();
}

class _RecipeIdeasBodyState extends State<_RecipeIdeasBody> {
  /// True once the checkmark animation has played for the loaded recipes.
  bool _hasPlayedReady = false;

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return BlocConsumer<
      DisplayReceipesBasedOnIngredientUserPreferenceController,
      DisplayReceipesBasedOnIngredientUserPreferenceState
    >(
      listener: (context, state) {
        if (state is DisplayReceipesBasedOnIngredientUserPreferenceLoading &&
            _hasPlayedReady) {
          setState(() => _hasPlayedReady = false);
        }
      },
      builder: (context, state) {
        if (state is DisplayReceipesBasedOnIngredientUserPreferenceLoading) {
          return const _LoadingView(isReady: false);
        }

        if (state is DisplayReceipesBasedOnIngredientUserPreferenceError) {
          return switch (state.error) {
            GenRecipeErrorCode.ingredientNotFound => _GenerationFailedView(
              message: appTexts.ingredientNotFound,
              actionLabel: appTexts.goToInventory,
              onAction: () => context.go('/inventory-screen'),
            ),
            GenRecipeErrorCode.userPreferenceNotFound => _GenerationFailedView(
              message: appTexts.userPreferenceNotFound,
              actionLabel: appTexts.goToChoosePreferences,
              onAction: () => context.go('/profil-screen'),
            ),
            GenRecipeErrorCode.internalServerError => _GenerationFailedView(
              message: appTexts.internalServerError,
              actionLabel: appTexts.retry,
              onAction: () => context
                  .read<
                    DisplayReceipesBasedOnIngredientUserPreferenceController
                  >()
                  .load(),
            ),
          };
        }

        final receipes =
            (state as DisplayReceipesBasedOnIngredientUserPreferenceLoaded)
                .receipes;

        // An empty answer is not a recipe: it is told as such, not celebrated.
        if (receipes.isEmpty) {
          return _GenerationFailedView(
            message: appTexts.cannotGenerateReceipeIdeas,
            actionLabel: appTexts.retry,
            onAction: () => context
                .read<
                  DisplayReceipesBasedOnIngredientUserPreferenceController
                >()
                .load(),
          );
        }

        if (!_hasPlayedReady) {
          return _LoadingView(
            isReady: true,
            onReadyAnimationEnd: () => setState(() => _hasPlayedReady = true),
          );
        }

        return _DisplayLoadedRecipe(receipes: receipes);
      },
    );
  }
}

/// Generation could not give a recipe: why, and what the user can do about it.
class _GenerationFailedView extends StatelessWidget {
  const _GenerationFailedView({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: homeFridgeTileBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: optionTerraColor,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: robotoFontFamily,
                fontWeight: FontWeight.w400,
                fontSize: 13,
                height: 1.5,
                color: recipeLoaderInkColor.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            OnboardingPrimaryButton(label: actionLabel, onPressed: onAction),
          ],
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView({required this.isReady, this.onReadyAnimationEnd});

  final bool isReady;
  final VoidCallback? onReadyAnimationEnd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: RecipeGenerationLoader(
          isReady: isReady,
          onReadyAnimationEnd: onReadyAnimationEnd,
        ),
      ),
    );
  }
}

class _DisplayLoadedRecipe extends StatelessWidget {
  const _DisplayLoadedRecipe({required this.receipes});

  final List<UserRecipeV2> receipes;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20, top: 15),
      itemCount: receipes.length,
      itemBuilder: (context, index) => ReceipeItem(
        receipe: receipes[index],
        redirectionPath: '/recipe-details',
      ),
    );
  }
}
