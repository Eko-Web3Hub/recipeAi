import 'dart:async';
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/analytics/analytics_event.dart';
import 'package:recipe_ai/analytics/analytics_repository.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/kitchen/domain/repositories/kitchen_inventory_repository.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';
import 'package:recipe_ai/user_account/domain/repositories/user_account_meta_data_repository.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:rxdart/rxdart.dart';

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
    this.appLanguage = AppLanguage.en,
  });

  final List<Category> categories;
  final List<Ingredient> ingredients;
  final List<Ingredient> ingredientsAddedByUser;
  final List<Ingredient> ingredientsSuggested;
  final bool isBusy;
  final String? categoryIdSelected;
  final AppLanguage appLanguage;

  @override
  List<Object?> get props => [
        categories,
        ingredients,
        ingredientsSuggested,
        categoryIdSelected,
        ingredientsAddedByUser,
        isBusy,
        appLanguage,
      ];

  InventoryState copyWith({
    List<Category>? categories,
    List<Ingredient>? ingredients,
    List<Ingredient>? ingredientsSuggested,
    List<Ingredient>? ingredientsAddedByUser,
    bool? isBusy,
    String? categoryIdSelected,
    AppLanguage? appLanguage,
  }) {
    return InventoryState(
      categories: categories ?? this.categories,
      ingredients: ingredients ?? this.ingredients,
      ingredientsSuggested: ingredientsSuggested ?? this.ingredientsSuggested,
      ingredientsAddedByUser:
          ingredientsAddedByUser ?? this.ingredientsAddedByUser,
      isBusy: isBusy ?? this.isBusy,
      categoryIdSelected: categoryIdSelected ?? this.categoryIdSelected,
      appLanguage: appLanguage ?? this.appLanguage,
    );
  }
}

//controller for inventory screen
class InventoryController extends Cubit<InventoryState> {
  final IInventoryRepository _inventoryRepository;
  final IKitchenInventoryRepository _kitchenInventoryRepository;
  final IAuthUserService _authUserService;
  final IAnalyticsRepository _analyticsRepository;
  final IUserAccountMetaDataRepository _userAccountMetaDataRepository;

  InventoryController(
    this._inventoryRepository,
    this._kitchenInventoryRepository,
    this._authUserService,
    this._analyticsRepository,
    this._userAccountMetaDataRepository,
  ) : super(InventoryState()) {
    listenToQuerySearch();
    loadCategories();
    loadIngredientsAdded();
    watchAccountMetaData();
  }

  final _searchController = StreamController<String>.broadcast();

  void onSelectCategory(String categoryId) {
    emit(state.copyWith(categoryIdSelected: categoryId));
    loadIngredients(categoryId);
  }

  void closeIngredientsSuggested() {
    emit(state.copyWith(ingredientsSuggested: []));
  }

  void listenToQuerySearch() {
    _searchController.stream
        .debounceTime(Duration(milliseconds: 200))
        .distinct()
        .listen(
      (query) async {
        if (query.isEmpty) {
          emit(state.copyWith(ingredientsSuggested: []));
          return;
        }
        final results = await _inventoryRepository.searchIngredients(query);
        log("Results: $results");
        if (results.isEmpty && query.isNotEmpty) {
          emit(state.copyWith(ingredientsSuggested: [
            Ingredient(
                name: query,
                quantity: '1',
                date: DateTime.now(),
                id: EntityId(query))
          ]));
        } else {
          emit(state.copyWith(ingredientsSuggested: results));
        }
      },
    );
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

      //get new ingredients loaded by user
      final newIngredientsAdded =
          await _kitchenInventoryRepository.getIngredientsAddedByUser(uid);
      refreshIngredients(newIngredientsAdded);
      _analyticsRepository.logEvent(
        IngredientManuallyAddedEvent(),
      );
    } catch (e) {
      //
    }
  }

  Future<void> removeIngredient(Ingredient ingredient) async {
    try {
      final uid = _authUserService.currentUser!.uid;
      _kitchenInventoryRepository.removeIngredient(
          uid: uid, ingredientId: ingredient.id!);

      //refresh ingredients list
      final ingredients = await _inventoryRepository
          .getIngredients(state.categoryIdSelected ?? '');

      List<Ingredient> filteredIngredients = ingredients.where((ingredient) {
        return !state.ingredientsAddedByUser.any((addedIngredient) =>
            addedIngredient.name.toLowerCase() ==
            ingredient.name.toLowerCase());
      }).toList();
      emit(state.copyWith(ingredients: filteredIngredients));
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

  Future<void> searchIngredients(String query) async {
    _searchController.add(query);
  }

  void refreshIngredients(List<Ingredient> ingredients) {
    List<Ingredient> filteredIngredients =
        state.ingredients.where((ingredient) {
      return !ingredients.any((addedIngredient) =>
          addedIngredient.name.toLowerCase() == ingredient.name.toLowerCase());
    }).toList();
    emit(state.copyWith(ingredients: filteredIngredients));
  }

  Future<void> watchAccountMetaData() async {
    final uid = _authUserService.currentUser!.uid;
    _userAccountMetaDataRepository.watchUserAccount(uid).listen(
      (userAccountMetaData) {
        if (userAccountMetaData != null) {
          emit(state.copyWith(
            appLanguage: userAccountMetaData.appLanguage,
          ));
        }
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
    _inventoryRepository.watchIngredients(categoryId).listen(
      (ingredientsFetched) {
        // Filtrer les ingrédients en comparant les id
        List<Ingredient> filteredIngredients =
            ingredientsFetched.where((ingredient) {
          return !state.ingredientsAddedByUser.any((addedIngredient) =>
              addedIngredient.name.toLowerCase() ==
              ingredient.name.toLowerCase());
        }).toList();
        emit(state.copyWith(ingredients: filteredIngredients));
      },
    );
  }
}
