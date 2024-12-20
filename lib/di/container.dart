import 'package:get_it/get_it.dart';
import 'package:recipe_ai/di/module.dart';

typedef DiContainer = GetIt;

DiContainer di = GetIt.instance;

extension DiContainerWithModules on DiContainer {
  void registerModule(IDiModule module) {
    module.register(this);
  }
}
