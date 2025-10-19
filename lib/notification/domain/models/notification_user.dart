enum NotificationUserStatus { enabled, disabled, authorized, unauthorized }

class NotificationUser {
  const NotificationUser({
    required this.status,
  });

  factory NotificationUser.fromJson(Map<String, dynamic> json) {
    return NotificationUser(
      status: NotificationUserStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
    );
  }

  NotificationUser disable() => _copyWith(
        status: NotificationUserStatus.disabled,
      );

  NotificationUser _copyWith({
    NotificationUserStatus? status,
  }) {
    return NotificationUser(
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status.name,
      };

  final NotificationUserStatus status;
}
