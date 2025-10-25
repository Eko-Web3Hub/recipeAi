import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/home/presentation/home_screen.dart';
import 'package:recipe_ai/home/presentation/translated_text.dart';
import 'package:recipe_ai/kitchen/presentation/kitchen_inventory_screen.dart';
import 'package:recipe_ai/receipe/application/user_recipe_service.dart';
import 'package:recipe_ai/saved_receipe/presentation/saved_receipe_controller.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/user_preferences/presentation/components/custom_progress.dart';
import 'package:recipe_ai/utils/constant.dart';

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
          title: translationController.currentLanguage.favorite,
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
    return BlocProvider(
      create: (context) => SavedReceipeController(
        di<IUserRecipeService>(),
      ),
      child: Builder(
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: horizontalScreenPadding,
            ),
            child: BlocBuilder<SavedReceipeController, SavedReceipeState>(
              builder: (context, state) {
                if (state is SavedReceipeStateLoading) {
                  return const Center(
                    child: CustomProgress(
                      color: Colors.black,
                    ),
                  );
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
                      ? const NoFavoriteRecipeSaved()
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 20, top: 15),
                          itemBuilder: (context, index) {
                            final data = state.savedReceipes[index];
                            return ReceipeItem(
                              key: ValueKey(data.id),
                              receipe: data,
                            );
                          },
                          itemCount: state.savedReceipes.length,
                        );
                }

                return const SizedBox();
              },
            ),
          );
        },
      ),
    );
  }
}

class NoFavoriteRecipeSaved extends StatelessWidget {
  const NoFavoriteRecipeSaved({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TranslatedText(
        textSelector: (lang) => lang.noSavedReceipes,
        style: descriptionPlaceHolderStyle,
        textAlign: TextAlign.center,
      ),
    );
  }
}
