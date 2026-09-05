import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/di/module.dart';

class ShoppingModule implements IDiModule {
  const ShoppingModule();

  @override
  void register(DiContainer di) {
    // No dependencies to register yet — controller uses mock data.
    // Repositories will be registered here when the API is ready.
  }
}
