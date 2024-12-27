import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/di/module.dart';
import 'package:recipe_ai/kitchen/domain/repositories/kitchen_inventory_repository.dart';
import 'package:recipe_ai/kitchen/domain/repositories/receipes_based_on_ingredient_user_preference_repository.dart';
import 'package:recipe_ai/kitchen/infrastructure/kitchen_inventory_repository.dart';
import 'package:recipe_ai/kitchen/infrastructure/receipes_based_on_ingredient_user_preference_repository.dart';

class KitchenModule implements IDiModule {
  const KitchenModule();
  @override
  void register(DiContainer di) {
    di.registerLazySingleton<IKitchenInventoryRepository>(
      () {
        return KitchenInventoryRepository(firestore: di<FirebaseFirestore>());
      },
    );
    di.registerLazySingleton<
        IReceipesBasedOnIngredientUserPreferenceRepository>(
      () => FastApiReceipesBasedOnIngredientUserPreferenceRepository(
        di<Dio>(),
      ),
    );
  }
}
