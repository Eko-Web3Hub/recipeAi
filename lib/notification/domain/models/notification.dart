import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationData {
  final String title;
  final String body;
  final DateTime? timestamp;
  final bool isRead;
  final Map<String, dynamic> data;

  NotificationData({
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

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      title: json['title'] as String,
      body: json['body'] as String,
      timestamp: (json['updated_at'] as Timestamp).toDate(),
      isRead: json['is_read'] as bool,
      data: json['data'] as Map<String, dynamic>,
    );
  }

  NotificationData _copyWith({
    String? title,
    String? body,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return NotificationData(
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }
}
