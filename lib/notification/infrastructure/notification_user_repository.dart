import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/notification/domain/infrastructure/notification_user_repository.dart';
import 'package:recipe_ai/notification/domain/models/notification_user.dart';

class FirestoreNotificationUserRepository
    implements INotificationUserRepository {
  FirestoreNotificationUserRepository._(
    this._firestore,
  );

  FirestoreNotificationUserRepository.inject()
      : this._(
          di<FirebaseFirestore>(),
        );

  final FirebaseFirestore _firestore;

  static const String _notificationUser = 'NotificationUser';

  @override
  Future<void> save(
    EntityId uid,
    NotificationUser userNotification,
  ) async {
    await _firestore
        .collection(_notificationUser)
        .doc(uid.value)
        .set(userNotification.toJson());
  }

  @override
  Future<NotificationUser?> get(EntityId uid) async {
    final doc =
        await _firestore.collection(_notificationUser).doc(uid.value).get();

    if (doc.exists) {
      return NotificationUser.fromJson(doc.data()!);
    } else {
      return null;
    }
  }

  @override
  Stream<NotificationUser?> watch(EntityId uid) {
    return _firestore
        .collection(_notificationUser)
        .doc(uid.value)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return NotificationUser.fromJson(snapshot.data()!);
      } else {
        return null;
      }
    });
  }
}
