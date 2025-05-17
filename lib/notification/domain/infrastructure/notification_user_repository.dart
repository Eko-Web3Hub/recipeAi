import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/notification/domain/models/notification_user.dart';

abstract class INotificationUserRepository {
  Future<void> save(
    EntityId uid,
    NotificationUser userNotification,
  );
}
