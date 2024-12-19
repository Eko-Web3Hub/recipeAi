import 'package:flutter/material.dart';
import 'package:recipe_ai/utils/app_text.dart';
import 'package:recipe_ai/utils/styles.dart';

const notificationFilters = [
  AppText.allNotifications,
  AppText.readNotification,
  AppText.unreadNotification,
];

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: notificationFilters
              .map<Widget>(
                (filter) => Expanded(
                  child: Text(
                    filter,
                    style: smallerTextStyle,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
