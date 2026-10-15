import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/di/module.dart';
import 'package:recipe_ai/shopping/domain/repositories/shopping_list_repository.dart';
import 'package:recipe_ai/shopping/infrastructure/shopping_list_repository.dart';

class ShoppingModule implements IDiModule {
  const ShoppingModule();

  @override
  void register(DiContainer di) {
    di.registerLazySingleton<IShoppingListRepository>(
      () => ShoppingListRepository(firestore: di<FirebaseFirestore>()),
    );
  }
}
