import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/kitchen/presentation/kitchen_inventory_screen.dart';
import 'package:recipe_ai/utils/app_text.dart';

class UpdateUserPreferenceScreen extends StatelessWidget {
  const UpdateUserPreferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: KitchenInventoryAppBar(
          arrowLeftOnPressed: () => context.go('/profil-screen'),
          title: AppText.updateUserPreference,
        ),
        body: Column(
          children: [],
        ),
      ),
    );
  }
}
