import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/notification/domain/models/notification_user.dart';
import 'package:recipe_ai/notification/presentation/notification_user_controller.dart';
import 'package:recipe_ai/onboarding/presentation/notification_permission_screen.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

/// Profile screen to turn the notifications on or off, laid out like the
/// onboarding priming screen.
class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return Scaffold(
      backgroundColor: recipeLoaderGreenColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 26),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                appTexts.notification,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: robotoSlabFontFamily,
                  fontWeight: FontWeight.w600,
                  fontSize: 34,
                  height: 1.05,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              const NotificationPreviewCard(),
              const SizedBox(height: 40),
              Text(
                appTexts.notificationPermissionWhy,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: robotoFontFamily,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                appTexts.notificationPermissionBody,
                textAlign: TextAlign.center,
                style: notificationPrimingBodyStyle,
              ),
              const SizedBox(height: 32),
              const _NotificationSwitchCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationSwitchCard extends StatelessWidget {
  const _NotificationSwitchCard();

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return BlocBuilder<NotificationUserController, NotificationUser?>(
      builder: (context, notificationUser) {
        final status = notificationUser?.status;

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(18, 8, 12, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      appTexts.notificationSettingsReceive,
                      style: const TextStyle(
                        fontFamily: robotoFontFamily,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: recipeLoaderInkColor,
                      ),
                    ),
                  ),
                  Switch(
                    activeTrackColor: recipeLoaderGreenColor,
                    thumbColor: WidgetStateProperty.all(Colors.white),
                    value: status == NotificationUserStatus.authorized,
                    onChanged: (value) => context
                        .read<NotificationUserController>()
                        .toggleNotification(value),
                  ),
                ],
              ),
            ),
            if (status == NotificationUserStatus.unauthorized) ...[
              const SizedBox(height: 14),
              Text(
                appTexts.notificationSettingsBlocked,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: robotoFontFamily,
                  fontWeight: FontWeight.w500,
                  fontSize: 12.5,
                  height: 1.45,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
