import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/presentation/components/custom_snack_bar.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/home/presentation/home_screen.dart';
import 'package:recipe_ai/home/presentation/receipe_item_controller.dart';
import 'package:recipe_ai/kitchen/domain/repositories/receipes_based_on_ingredient_user_preference_repository.dart';
import 'package:recipe_ai/kitchen/presentation/display_receipes_based_on_ingredient_user_preference_controller.dart';
import 'package:recipe_ai/kitchen/presentation/kitchen_inventory_screen.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository.dart';
import 'package:recipe_ai/user_preferences/presentation/components/custom_progress.dart';
import 'package:recipe_ai/utils/app_text.dart';
import 'package:recipe_ai/utils/constant.dart';

class DisplayReceipesBasedOnIngredientUserPreferenceScreen
    extends StatelessWidget {
  const DisplayReceipesBasedOnIngredientUserPreferenceScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DisplayReceipesBasedOnIngredientUserPreferenceController(
        di<IAuthUserService>(),
        di<IReceipesBasedOnIngredientUserPreferenceRepository>(),
      ),
      child: SafeArea(
        child: Scaffold(
          appBar: KitchenInventoryAppBar(
            title: AppText.receipeIdeas,
            arrowLeftOnPressed: () => context.go(
              '/home/kitchen-inventory',
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
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: [
        const Gap(120),
        Text(
          AppText.receipeIdeasDescription,
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

  final List<Receipe> receipes;

  @override
  Widget build(BuildContext context) {
    return receipes.isEmpty
        ? Center(
            child: Text(
              AppText.cannotGenerateReceipeIdeas,
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: Colors.black,
                  ),
              textAlign: TextAlign.center,
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.only(bottom: 20, top: 15),
            itemCount: receipes.length,
            itemBuilder: (context, index) => BlocProvider(
              create: (context) => ReceipeItemController(
                receipes[index],
                di<IUserReceipeRepository>(),
                di<IAuthUserService>(),
              ),
              child: BlocListener<ReceipeItemController, ReceipeItemState>(
                listener: (context, state) {
                  if (state is ReceipeItemStateError) {
                    showSnackBar(context, state.message, isError: true);
                  }
                },
                child: BlocBuilder<ReceipeItemController, ReceipeItemState>(
                  builder: (context, state) {
                    return ReceipeItem(
                      receipe: receipes[index],
                      isSaved: state is ReceipeItemStateSaved,
                      onTap: () {
                        if (state is ReceipeItemStateSaved) {
                          context.read<ReceipeItemController>().removeReceipe();
                        } else {
                          context.read<ReceipeItemController>().saveReceipe();
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          );
  }
}
