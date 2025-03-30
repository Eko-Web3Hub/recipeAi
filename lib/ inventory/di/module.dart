import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_ai/%20inventory/domain/repositories/inventory_repository.dart';
import 'package:recipe_ai/%20inventory/infrastructure/repositories/inventory_repository.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/di/module.dart';

class InventoryModule implements IDiModule {
  const InventoryModule();
  @override
  void register(DiContainer di) {
    di.registerLazySingleton<IInventoryRepository>(() {
      return InventoryRepository(firestore: di<FirebaseFirestore>());
    });
  }
}
