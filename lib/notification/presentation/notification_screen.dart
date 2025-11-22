import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/home/presentation/profile_screen.dart';
import 'package:recipe_ai/kitchen/presentation/kitchen_inventory_screen.dart';
import 'package:recipe_ai/notification/application/general_notification_service.dart';
import 'package:recipe_ai/notification/domain/models/notification.dart';
import 'package:recipe_ai/notification/presentation/notification_screen_controller.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/user_preferences/presentation/components/custom_circular_loader.dart';
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
      body: BlocProvider(
        create: (_) => NotificationScreenController.inject(),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Gap(10),
              BlocBuilder<NotificationScreenController,
                  NotificationScreenState>(
                builder: (context, state) {
                  if (state is NotificationScreenLoading) {
                    return Center(
                      child: CustomCircularLoader(),
                    );
                  } else if (state is NotificationScreenLoaded) {
                    final notifications = state.notifications;
                    if (notifications.isEmpty) {
                      return _EmptyNotificationScreen();
                    }
                    return Column(
                      children: notifications
                          .map(
                            (notification) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: _NotificationCard(notification),
                            ),
                          )
                          .toList(),
                    );
                  }

                  return SizedBox.shrink();
                },
              ),
              const Gap(30),
            ],
          ),
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

    return Center(
      child: Column(
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
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard(
    this.notification,
  );

  final NotificationData notification;

  void onNotificationTap(BuildContext context) {
    _showNotificationDetails(
      context,
      notification,
    );
    di<IGeneralNotificationService>().markAsRead(notification.id);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;

    return GestureDetector(
      onTap: () => onNotificationTap(context),
      child: Container(
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
            _NotificationLogo(
              width: 48,
              height: 48,
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: width * 0.65,
                      child: Text(
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
                    ),
                    Visibility(
                      visible: !notification.isRead,
                      child: CircleNotificationBadge(),
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationLogo extends StatelessWidget {
  const _NotificationLogo({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: neutralGrey4Color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SvgPicture.asset(
        'assets/images/notification_icon_recipe.svg',
        width: 24,
        height: 24,
        fit: BoxFit.scaleDown,
      ),
    );
  }
}

class CircleNotificationBadge extends StatelessWidget {
  const CircleNotificationBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Color(0xffFF685F),
        shape: BoxShape.circle,
      ),
    );
  }
}

void _showNotificationDetails(
  BuildContext context,
  NotificationData notification,
) =>
    showDialog(
      context: context,
      builder: (BuildContext context) => DialogLayout(
        child: _NotificationDetails(
          notification: notification,
        ),
      ),
    );

class _NotificationDetails extends StatelessWidget {
  const _NotificationDetails({
    required this.notification,
  });

  final NotificationData notification;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _NotificationLogo(
          width: double.infinity,
          height: 70,
        ),
        const Gap(20),
        Text(
          notification.title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const Gap(4.0),
        Text(
          notification.body,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
