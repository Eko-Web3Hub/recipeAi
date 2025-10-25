import 'package:flutter/material.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/user_preferences/presentation/user_preference_update_widget.dart';
import 'package:recipe_ai/utils/styles.dart';

class UpdateUserPreferenceScreen extends StatelessWidget {
  const UpdateUserPreferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Text(
          appTexts.updateUserPreference,
          style: appBarTextStyle,
        ),
      ),
      body: const UserPreferenceUpdateWidget(),
    );
  }
}
