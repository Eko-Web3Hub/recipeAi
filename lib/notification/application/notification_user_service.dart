import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/notification/domain/infrastructure/notification_user_repository.dart';
import 'package:recipe_ai/notification/domain/models/notification_user.dart';

abstract class INotificationUserService {
  Future<void> save(
    NotificationUser userNotification,
  );
}

class NotificationUserService implements INotificationUserService {
  const NotificationUserService._(
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
}
