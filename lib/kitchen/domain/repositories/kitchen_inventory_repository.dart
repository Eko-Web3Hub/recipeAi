import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';

abstract class IKitchenInventoryRepository {

   Stream<List<Ingredient>> watchIngredientsAddedByUser(EntityId uid);
   Future<List<Ingredient>> getIngredientsAddedByUser(EntityId uid);
   Future<void> save(EntityId uid, Ingredient ingredient);
   Future<List<Ingredient>> searchForIngredients(EntityId uid, String query);

}