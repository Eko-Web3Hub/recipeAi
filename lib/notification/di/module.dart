import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/di/module.dart';
import 'package:recipe_ai/notification/application/fcm_token_service.dart';
import 'package:recipe_ai/notification/application/general_notification_service.dart';
import 'package:recipe_ai/notification/application/notification_user_service.dart';
import 'package:recipe_ai/notification/domain/infrastructure/notification_user_repository.dart';
import 'package:recipe_ai/notification/infrastructure/notification_user_repository.dart';

class NotificationModule implements IDiModule {
  @override
  void register(DiContainer di) {
    di.registerLazySingleton<INotificationUserRepository>(
      () => FirestoreNotificationUserRepository.inject(),
    );

    di.registerSingleton<FCMTokenService>(
      FCMTokenService.inject(di),
    );

    di.registerFactory<INotificationUserService>(
      () => NotificationUserService.inject(),
    );

    di.registerFactory<IGeneralNotificationService>(
      () => GeneralNotificationService.inject(),
    );
  }
}
