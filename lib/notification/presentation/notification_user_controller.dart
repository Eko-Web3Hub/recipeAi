import 'dart:async';

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
  ) : super(null) {
    _load();
  }

  NotificationUserController.inject()
      : this(
          di<FCMTokenService>(),
          di<INotificationUserService>(),
        );

  void requestPermission(bool hasJustEnabled) async {
    final currentNotificationUser = await _notificationUserService.get();

    if (!hasJustEnabled &&
        currentNotificationUser != null &&
        (currentNotificationUser.status == NotificationUserStatus.disabled ||
            currentNotificationUser.status ==
                NotificationUserStatus.unauthorized)) {
      return;
    }

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

  void toggleNotification(bool toggleNotifValue) async {
    if (state != null && state!.status == NotificationUserStatus.authorized) {
      final newState = await _notificationUserService.disable();
      safeEmit(newState);

      return;
    }

    requestPermission(toggleNotifValue);
  }

  void _load() {
    _subscription = _notificationUserService.watchUserNotification
        .listen((notificationUser) {
      safeEmit(notificationUser);
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  final FCMTokenService _fcmTokenService;
  final INotificationUserService _notificationUserService;

  StreamSubscription<NotificationUser?>? _subscription;
}
