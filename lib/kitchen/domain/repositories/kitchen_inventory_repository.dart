import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';

abstract class IKitchenInventoryRepository {

   Future<List<Ingredient>> getIngredientsAddedByUser(EntityId uid);
   Future<void> save(EntityId uid, Ingredient ingredient);
   Future<List<Ingredient>> searchForIngredients(EntityId uid, String query);

}