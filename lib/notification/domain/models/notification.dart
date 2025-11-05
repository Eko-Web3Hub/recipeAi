import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationData {
  final String title;
  final String body;
  final DateTime? timestamp;

  NotificationData({
    required this.title,
    required this.body,
    required this.timestamp,
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
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  NotificationData _copyWith({
    String? title,
    String? body,
    DateTime? timestamp,
  }) {
    return NotificationData(
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
