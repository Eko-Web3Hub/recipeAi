import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/presentation/components/custom_snack_bar.dart';
import 'package:recipe_ai/auth/presentation/components/main_btn.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/kitchen/domain/repositories/kitchen_inventory_repository.dart';
import 'package:recipe_ai/kitchen/presentation/kitchen_inventory_screen.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';
import 'package:recipe_ai/receipt_ticket_scan/presentation/receipt_ticket_scan_result_controller.dart';
import 'package:recipe_ai/utils/app_text.dart';
import 'package:recipe_ai/utils/styles.dart';

class ReceiptTicketScanResultScreen extends StatelessWidget {
  const ReceiptTicketScanResultScreen({
    super.key,
    required this.ingredients,
  });

  final List<Ingredient> ingredients;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReceiptTicketScanResultController(
        di<IKitchenInventoryRepository>(),
        di<IAuthUserService>(),
        ingredients: ingredients,
      ),
      child: BlocListener<ReceiptTicketScanResultController,
          ReceiptTicketScanResultState>(
        listener: (context, state) {
          if (state is ReceiptTicketScanUpdateKitechenInventorySuccess) {
            context.go('/home/kitchen-inventory');
          }
        },
        child: Builder(builder: (context) {
          return SafeArea(
            child: Scaffold(
              appBar: KitchenInventoryAppBar(
                title: AppText.scanReceiptTicketAppbar,
                arrowLeftOnPressed: () => context.go('/home/kitchen-inventory'),
              ),
              body: Column(
                children: [
                  const Gap(20.0),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                      ),
                      child: Text(
                        AppText.scanAiReceiptDescription,
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                              color: Colors.black,
                            ),
                      ),
                    ),
                  ),
                  const Gap(30.0),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemBuilder: (context, index) {
                        return Dismissible(
                          onDismissed: (direction) {
                            context
                                .read<ReceiptTicketScanResultController>()
                                .removeIngredient(index);
                            showSnackBar(context, AppText.ingredientRemoved);
                          },
                          direction: DismissDirection.endToStart,
                          background: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: Text(
                                  AppText.delete,
                                  style: normalSmallTextStyle,
                                ),
                              ),
                            ),
                          ),
                          key: UniqueKey(),
                          child: IngredientItem(
                            ingredient: ingredients[index],
                            getIngredientQuantity: (quantity) {
                              log(quantity.toString());
                              if (quantity != null) {
                                context
                                    .read<ReceiptTicketScanResultController>()
                                    .updateIngredient(
                                      index,
                                      int.parse(quantity),
                                    );
                              }
                            },
                          ),
                        );
                      },
                      itemCount: ingredients.length,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: MainBtn(
                      text: AppText.addToKitchenInvontory,
                      onPressed: context
                          .read<ReceiptTicketScanResultController>()
                          .addIngredientsToKitchenInventory,
                    ),
                  ),
                  const Gap(30.0),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
