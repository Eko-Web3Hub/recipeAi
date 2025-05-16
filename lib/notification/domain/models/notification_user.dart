enum NotificationUserStatus { enabled, disabled, authorized, unauthorized }

class NotificationUser {
  const NotificationUser({
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'status': status.name,
      };

  final NotificationUserStatus status;
}
