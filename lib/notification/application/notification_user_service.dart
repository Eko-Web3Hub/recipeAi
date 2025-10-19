import 'dart:async';

import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/notification/domain/infrastructure/notification_user_repository.dart';
import 'package:recipe_ai/notification/domain/models/notification_user.dart';

abstract class INotificationUserService {
  Stream<NotificationUser?> get watchUserNotification;

  Future<void> save(
    NotificationUser userNotification,
  );

  Future<NotificationUser> disable();

  Future<NotificationUser?> get();
}

class NotificationUserService implements INotificationUserService {
  NotificationUserService._(
    this._authUserService,
    this._notificationUserRepository,
  );

  NotificationUserService.inject()
      : this._(
          di<IAuthUserService>(),
          di<INotificationUserRepository>(),
        );

  @override
  Future<void> save(NotificationUser userNotification) {
    final uid = _authUserService.currentUser!.uid;

    return _notificationUserRepository.save(
      uid,
      userNotification,
    );
  }

  final IAuthUserService _authUserService;
  final INotificationUserRepository _notificationUserRepository;

  @override
  Stream<NotificationUser?> get watchUserNotification =>
      _notificationUserRepository.watch(
        _authUserService.currentUser!.uid,
      );

  @override
  Future<NotificationUser> disable() async {
    final currentNotificationUser = await get();
    assert(currentNotificationUser != null);
    final newNotificationUser = currentNotificationUser!.disable();

    save(newNotificationUser);

    return newNotificationUser;
  }

  Future<NotificationUser?> get() {
    final uid = _authUserService.currentUser!.uid;

    return _notificationUserRepository.get(
      uid,
    );
  }
}
