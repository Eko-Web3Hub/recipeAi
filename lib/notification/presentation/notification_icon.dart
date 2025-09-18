import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NotificationIcon extends StatelessWidget {
  const NotificationIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/notification-bing.svg',
    );
  }
}
