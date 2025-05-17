import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/notification/application/fcm_token_service.dart';
import 'package:recipe_ai/notification/application/notification_user_service.dart';
import 'package:recipe_ai/notification/domain/models/notification_user.dart';
import 'package:recipe_ai/utils/safe_emit.dart';

class NotificationUserController extends Cubit<NotificationUser?> {
  NotificationUserController(
    this._fcmTokenService,
    this._notificationUserService,
  ) : super(null);

  NotificationUserController.inject()
      : this(
          di<FCMTokenService>(),
          di<INotificationUserService>(),
        );

  void requestPermission() async {
    final status = await _fcmTokenService.requestPermission();
    final notificationUser = NotificationUser(
      status: status
          ? NotificationUserStatus.authorized
          : NotificationUserStatus.unauthorized,
    );

    await _notificationUserService.save(
      notificationUser,
    );

    safeEmit(notificationUser);
  }

  final FCMTokenService _fcmTokenService;
  final INotificationUserService _notificationUserService;
}
