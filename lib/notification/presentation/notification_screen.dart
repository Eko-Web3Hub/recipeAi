import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/kitchen/presentation/kitchen_inventory_screen.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/styles.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;
    return Scaffold(
      appBar: KitchenInventoryAppBar(
        title: appTexts.notification,
        arrowLeftOnPressed: () => context.pop(),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _EmptyNotificationScreen(),
        ],
      ),
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
        _NotificationCard(),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            offset: Offset(
              0,
              2,
            ),
            blurRadius: 16,
            color: Color(0xff063336).withOpacity(0.1),
          ),
        ],
      ),
    );
  }
}
