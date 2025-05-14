import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/di/module.dart';
import 'package:recipe_ai/notification/application/fcm_token_service.dart';

class NotificationModule implements IDiModule {
  @override
  void register(DiContainer di) {
    di.registerFactory<FCMTokenService>(
      () => FCMTokenService.inject(di),
    );
  }
}
