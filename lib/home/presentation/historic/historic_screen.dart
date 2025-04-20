import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/home/presentation/historic/historic_controller.dart';
import 'package:recipe_ai/home/presentation/home_screen.dart';
import 'package:recipe_ai/kitchen/presentation/kitchen_inventory_screen.dart';
import 'package:recipe_ai/receipe/application/user_recipe_service.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/user_preferences/presentation/components/custom_progress.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/styles.dart';

class HistoricScreen extends StatelessWidget {
  const HistoricScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return Scaffold(
      appBar: KitchenInventoryAppBar(
        title: appTexts.historic,
        arrowLeftOnPressed: () => context.go('/home'),
      ),
      body: BlocProvider(
        create: (context) => HistoricController(
          di<IUserRecipeService>(),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalScreenPadding,
          ),
          child: Column(
            children: [
              BlocBuilder<HistoricController, HistoricState>(
                builder: (context, historicState) {
                  if (historicState is HistoricLoadingState) {
                    return Expanded(
                      child: Center(
                        child: CustomProgress(
                          color: Colors.black,
                        ),
                      ),
                    );
                  }

                  if (historicState is HistoricLoadedState) {
                    final recipesHistoric = historicState.recipes;

                    if (recipesHistoric.isEmpty) {
                      return Center(
                        child: Text(
                          appTexts.emptyHistoric,
                          style: smallTextStyle,
                          textAlign: TextAlign.center,
                        ),
                      );
                    } else {
                      return Expanded(
                        child: ListView.builder(
                          itemCount: recipesHistoric.length,
                          itemBuilder: (context, index) => ReceipeItem(
                            key: ValueKey(recipesHistoric[index].id),
                            receipe: recipesHistoric[index],
                          ),
                        ),
                      );
                    }
                  }

                  return SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
