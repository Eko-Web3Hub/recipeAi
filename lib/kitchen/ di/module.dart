import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/di/module.dart';
import 'package:recipe_ai/kitchen/domain/repositories/kitchen_inventory_repository.dart';
import 'package:recipe_ai/kitchen/infrastructure/kitchen_inventory_repository.dart';

class KitchenModule implements IDiModule {
  const KitchenModule();
  @override
  void register(DiContainer di) {
    di.registerLazySingleton<IKitchenInventoryRepository>(
      () {
        return KitchenInventoryRepository(firestore: di<FirebaseFirestore>());
      },
    );
  }
}
