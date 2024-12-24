import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
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
        appBar: const KitchenInventoryAppBar(
          title: AppText.scanReceiptTicketAppbar,
        ),
        body: Column(
          children: [
            const Gap(20.0),
            Text(
              AppText.scanAiReceiptDescription,
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: Colors.black,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
