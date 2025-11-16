import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/notification/domain/models/notification.dart';
import 'package:recipe_ai/notification/infrastructure/general_notification.dart';

abstract class IGeneralNotificationService {
  Stream<List<NotificationData>> watchAll();
}

class GeneralNotificationService implements IGeneralNotificationService {
  final IAuthUserService _authUserService;
  final IGeneralNotification _generalNotificationRepository;

  GeneralNotificationService(
    this._authUserService,
    this._generalNotificationRepository,
  );

  GeneralNotificationService.inject()
      : this(
          di<IAuthUserService>(),
          di<IGeneralNotification>(),
        );

  @override
  Stream<List<NotificationData>> watchAll() {
    final uid = _authUserService.currentUser!.uid;
    return _generalNotificationRepository.watchAll(uid);
  }
}
