import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/kitchen/presentation/kitchen_inventory_screen.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';
import 'package:recipe_ai/utils/app_text.dart';

class ReceiptTicketScanResultScreen extends StatelessWidget {
  const ReceiptTicketScanResultScreen({
    super.key,
    required this.ingredients,
  });

  final List<Ingredient> ingredients;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: KitchenInventoryAppBar(
          title: AppText.scanReceiptTicketAppbar,
          arrowLeftOnPressed: () => context.pop(),
        ),
        body: Column(
          children: [
            const Gap(20.0),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
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
                  return IngredientItem(ingredient: ingredients[index]);
                },
                itemCount: ingredients.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
