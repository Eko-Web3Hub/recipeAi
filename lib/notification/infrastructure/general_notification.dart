import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/notification/domain/models/notification.dart';

abstract class IGeneralNotification {
  Stream<List<NotificationData>> watchAll(EntityId uid);
  Future<void> markAsRead(EntityId notificationId);
}

class GeneralNotification implements IGeneralNotification {
  const GeneralNotification(this._firestore);

  static const String notificationsCollection = 'Notifications';

  GeneralNotification.inject()
      : this(
          di<FirebaseFirestore>(),
        );

  final FirebaseFirestore _firestore;

  @override
  Stream<List<NotificationData>> watchAll(EntityId uid) {
    // Get all notifications for the user with status 'Sent', ordered by updated_at descending

    return _firestore
        .collection(notificationsCollection)
        .where('uid', isEqualTo: uid.value)
        .where('status', isEqualTo: 'Sent')
        .orderBy('updated_at', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => NotificationData.fromJson(
                  EntityId(doc.id),
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  @override
  Future<void> markAsRead(EntityId notificationId) => _firestore
          .collection(notificationsCollection)
          .doc(notificationId.value)
          .update({
        'is_read': true,
      });
}
