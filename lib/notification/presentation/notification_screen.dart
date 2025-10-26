import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/kitchen/presentation/kitchen_inventory_screen.dart';
import 'package:recipe_ai/notification/domain/models/notification.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/styles.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: KitchenInventoryAppBar(
        title: appTexts.notification,
        arrowLeftOnPressed: () => context.pop(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Gap(20),
            // _EmptyNotificationScreen(),
            _NotificationCard(
              NotificationData(
                title: 'Recipe Recomendation',
                body: 'Your order has delivered successfully',
              ),
            ),
          ],
        ),
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
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard(
    this.notification,
  );

  final NotificationData notification;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80,
      padding: EdgeInsets.only(
        top: 16,
        right: 13,
        bottom: 16,
        left: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            offset: Offset(
              1,
              2,
            ),
            blurRadius: 16,
            spreadRadius: 0,
            color: Color(0xff063336).withOpacity(0.1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: neutralGrey4Color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const Gap(12.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                notification.title,
                style: TextStyle(
                  fontFamily: 'SofiaPro',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  height: 1.30,
                  color: Color(0xff97A2B0),
                ),
              ),
              const Gap(4.0),
              Text(
                notification.body,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  height: 1.45,
                  color: neutralGrey2ColorNight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
