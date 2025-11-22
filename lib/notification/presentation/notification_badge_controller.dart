import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/notification/application/general_notification_service.dart';
import 'package:recipe_ai/utils/safe_emit.dart';

class NotificationBadgeController extends Cubit<bool> {
  NotificationBadgeController(this._notificationService) : super(false) {
    _load();
  }

  NotificationBadgeController.inject()
      : this(
          di<IGeneralNotificationService>(),
        );

  void _load() async {
    _subscription = _notificationService
        .hasUnreadNotification()
        .listen((hasUnreadNotifications) {
      safeEmit(hasUnreadNotifications);
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  final IGeneralNotificationService _notificationService;
  StreamSubscription<bool>? _subscription;
}
