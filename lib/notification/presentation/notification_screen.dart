import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/styles.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _EmptyNotificationScreen(),
      ],
    );
  }
}

class _EmptyNotificationScreen extends StatelessWidget {
  const _EmptyNotificationScreen();

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/icon/notificationPlaceHolder.png',
        ),
        const Gap(20),
        Text(
          appTexts.notificationEmptyTitle,
          style: descriptionPlaceHolderStyle,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
