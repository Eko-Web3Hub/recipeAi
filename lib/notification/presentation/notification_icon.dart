import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/notification/presentation/notification_badge_controller.dart';
import 'package:recipe_ai/notification/presentation/notification_screen.dart';

class NotificationIcon extends StatelessWidget {
  const NotificationIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationBadgeController.inject(),
      child: GestureDetector(
        onTap: () => context.push('/home/notification'),
        child: Stack(
          children: [
            SvgPicture.asset(
              'assets/images/notification-bing.svg',
            ),
            BlocBuilder<NotificationBadgeController, bool>(
              builder: (context, hasUnreadNotifications) {
                if (!hasUnreadNotifications) {
                  return SizedBox.shrink();
                }
                return Positioned(
                  right: 0,
                  child: CircleNotificationBadge(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
