import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_ai/ddd/entity.dart';

class NotificationData {
  final EntityId id;
  final String title;
  final String body;
  final DateTime? timestamp;
  final bool isRead;
  final Map<String, dynamic> data;

  NotificationData({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.isRead,
    required this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  factory NotificationData.fromJson(EntityId id, Map<String, dynamic> json) {
    return NotificationData(
      id: id,
      title: json['title'] as String,
      body: json['body'] as String,
      timestamp: (json['updated_at'] as Timestamp).toDate(),
      isRead: json['is_read'] as bool,
      data: json['data'] as Map<String, dynamic>,
    );
  }

  NotificationData _copyWith({
    EntityId? id,
    String? title,
    String? body,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return NotificationData(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }
}
