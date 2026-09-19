import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/di/module.dart';
import 'package:recipe_ai/fridge/domain/repositories/fridge_repository.dart';
import 'package:recipe_ai/fridge/infrastructure/fridge_repository.dart';

class FridgeModule implements IDiModule {
  const FridgeModule();

  @override
  void register(DiContainer di) {
    di.registerLazySingleton<IFridgeRepository>(
      () => FridgeRepository(firestore: di<FirebaseFirestore>()),
    );
    di.registerLazySingleton<IIngredientCatalogRepository>(
      () => IngredientCatalogRepository(firestore: di<FirebaseFirestore>()),
    );
  }
}
