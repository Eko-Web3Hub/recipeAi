import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/notification/application/general_notification_service.dart';
import 'package:recipe_ai/notification/domain/models/notification.dart';

abstract class NotificationScreenState {}

class NotificationScreenLoading extends NotificationScreenState {}

class NotificationScreenLoaded extends NotificationScreenState {
  final List<NotificationData> notifications;

  NotificationScreenLoaded(this.notifications);
}

class NotificationScreenController extends Cubit<NotificationScreenState> {
  NotificationScreenController(
    this._generalNotificationService,
  ) : super(NotificationScreenLoading()) {
    _load();
  }

  NotificationScreenController.inject()
      : this(
          di<IGeneralNotificationService>(),
        );

  final IGeneralNotificationService _generalNotificationService;

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  void _load() {
    _subscription = _generalNotificationService.watchAll().listen(
      (notifications) {
        emit(
          NotificationScreenLoaded(notifications),
        );
      },
    );
  }

  StreamSubscription<List<NotificationData>>? _subscription;
}
