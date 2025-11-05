import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/notification/domain/models/notification.dart';

abstract class IGeneralNotification {
  Future<void> store(
    EntityId uid,
    NotificationData notification,
  );

  Stream<List<NotificationData>> watchAll(EntityId uid);
}

class GeneralNotification implements IGeneralNotification {
  const GeneralNotification(this._firestore);

  static const String notificationsCollection = 'Notifications';
  static const String generalCollection = 'General';

  GeneralNotification.inject()
      : this(
          di<FirebaseFirestore>(),
        );

  @override
  Future<void> store(
    EntityId uid,
    NotificationData notification,
  ) =>
      _firestore
          .collection(notificationsCollection)
          .doc(uid.value)
          .collection(generalCollection)
          .add(
            notification.toJson(),
          );

  final FirebaseFirestore _firestore;

  @override
  Stream<List<NotificationData>> watchAll(EntityId uid) {
    return _firestore
        .collection(notificationsCollection)
        .doc(uid.value)
        .collection(generalCollection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => NotificationData.fromJson(
                  doc.data(),
                ),
              )
              .toList(),
        );
  }
}
