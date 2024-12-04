import 'package:recipe_ai/auth/di/module.dart';
import 'package:recipe_ai/di/container.dart';

abstract class IDiModule {
  void register(DiContainer di);
}

class AppModule implements IDiModule {
  @override
  void register(DiContainer di) {
    di.registerModule(
      AuthModule(),
    );
  }
}
