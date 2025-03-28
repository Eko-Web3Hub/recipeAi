import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/kitchen/domain/repositories/kitchen_inventory_repository.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';

import '../domain/model/category.dart';
import '../domain/repositories/inventory_repository.dart';

final class InventoryState extends Equatable {
  const InventoryState({
    this.categories = const [],
    this.ingredients = const [],
    this.ingredientsSuggested = const [],
    this.ingredientsAddedByUser = const [],
    this.isBusy = false,
    this.categoryIdSelected,
  });

  final List<Category> categories;
  final List<Ingredient> ingredients;
  final List<Ingredient> ingredientsAddedByUser;
  final List<Ingredient> ingredientsSuggested;
  final bool isBusy;
  final String? categoryIdSelected;

  @override
  List<Object?> get props => [
        categories,
        ingredients,
        ingredientsSuggested,
        categoryIdSelected,
        ingredientsAddedByUser
      ];

  InventoryState copyWith({
    List<Category>? categories,
    List<Ingredient>? ingredients,
    List<Ingredient>? ingredientsSuggested,
    List<Ingredient>? ingredientsAddedByUser,
    bool? isBusy,
    String? categoryIdSelected,
  }) {
    return InventoryState(
      categories: categories ?? this.categories,
      ingredients: ingredients ?? this.ingredients,
      ingredientsSuggested: ingredientsSuggested ?? this.ingredientsSuggested,
      ingredientsAddedByUser:
          ingredientsAddedByUser ?? this.ingredientsAddedByUser,
      isBusy: isBusy ?? this.isBusy,
      categoryIdSelected: categoryIdSelected ?? this.categoryIdSelected,
    );
  }
}

//controller for inventory screen
class InventoryController extends Cubit<InventoryState> {
  final IInventoryRepository _inventoryRepository;
  final IKitchenInventoryRepository _kitchenInventoryRepository;
  final IAuthUserService _authUserService;

  InventoryController(this._inventoryRepository,
      this._kitchenInventoryRepository, this._authUserService)
      : super(InventoryState()) {
    loadCategories();
    loadIngredientsAdded();
  }

  void onSelectCategory(String categoryId) {
    emit(state.copyWith(categoryIdSelected: categoryId));
    loadIngredients(categoryId);
  }

  bool isIngredientSelected(Ingredient ingredient) {
    final index = state.ingredientsAddedByUser.indexWhere(
      (element) => element.name == ingredient.name,
    );
    return index != -1;
  }

  Future<void> addIngredient(Ingredient ingredient) async {
    try {
      final uid = _authUserService.currentUser!.uid;
      _kitchenInventoryRepository.addIngredient(uid, ingredient);
    } catch (e) {
      //
    }
  }

  Future<void> removeIngredient(Ingredient ingredient) async {
    try {
      final uid = _authUserService.currentUser!.uid;
      _kitchenInventoryRepository.removeIngredient(
          uid: uid, ingredientId: ingredient.id!);
    } catch (e) {
      //
    }
  }

  Future<void> loadIngredientsAdded() async {
    final uid = _authUserService.currentUser!.uid;

    _kitchenInventoryRepository.watchIngredientsAddedByUser(uid).listen(
      (ingredientsFetched) {
        emit(state.copyWith(ingredientsAddedByUser: ingredientsFetched));
      },
    );
  }

  Future<void> loadCategories() async {
    _inventoryRepository.getCategories().listen(
      (categoriesFetched) {
        if (categoriesFetched.isNotEmpty) {
          emit(state.copyWith(
              categories: categoriesFetched,
              categoryIdSelected: categoriesFetched.first.id?.value));
          loadIngredients(categoriesFetched.first.id?.value ?? '');
        }
      },
    );
  }

  Future<void> loadIngredients(String categoryId) async {
    _inventoryRepository.getIngredients(categoryId).listen(
      (ingredientsFetched) {
        emit(state.copyWith(ingredients: ingredientsFetched));
      },
    );
  }
}
