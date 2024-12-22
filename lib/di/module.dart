import 'package:recipe_ai/auth/di/module.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/di/core_module.dart';
import 'package:recipe_ai/kitchen/%20di/module.dart';
import 'package:recipe_ai/receipe/di/module.dart';
import 'package:recipe_ai/user_preferences/di/module.dart';

abstract class IDiModule {
  void register(DiContainer di);
}

class AppModule implements IDiModule {
  @override
  void register(DiContainer di) {
    di.registerModule(
      const CoreModule(),
    );
    di.registerModule(
      const AuthModule(),
    );
    di.registerModule(
      const UserPreferencesModule(),
    );
      di.registerModule(
      const ReceipeModule(),
    );
     di.registerModule(
       const KitchenModule(),
    );
  }
}
