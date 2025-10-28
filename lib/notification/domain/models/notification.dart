class NotificationData {
  final String title;
  final String body;

  NotificationData({
    required this.title,
    required this.body,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
    };
  }
}
