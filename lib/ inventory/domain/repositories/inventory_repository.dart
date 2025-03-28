import 'package:recipe_ai/%20inventory/domain/model/category.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';

abstract class IInventoryRepository {
  Stream<List<Category>> getCategories();
  Stream<List<Ingredient>> getIngredients(String categoryId);
  Future<List<Ingredient>> searchIngredients(String query);
}
