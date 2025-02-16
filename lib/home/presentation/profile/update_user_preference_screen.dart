import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/kitchen/presentation/kitchen_inventory_screen.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/user_preferences/presentation/user_preference_update_widget.dart';

class UpdateUserPreferenceScreen extends StatelessWidget {
  const UpdateUserPreferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return SafeArea(
      child: Scaffold(
        appBar: KitchenInventoryAppBar(
          arrowLeftOnPressed: () => context.go('/profil-screen'),
          title: appTexts.updateUserPreference,
        ),
        body: const UserPreferenceUpdateWidget(),
      ),
    );
  }
}
