import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/kitchen/domain/repositories/kitchen_inventory_repository.dart';
import 'package:recipe_ai/kitchen/infrastructure/kitchen_inventory_repository.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';

abstract class KitchenState extends Equatable {
  const KitchenState();
  @override
  List<Object?> get props => [];
}

class KitchenStateLoading extends KitchenState {
  const KitchenStateLoading();
}

class KitchenStateLoaded extends KitchenState {
  final List<Ingredient> ingredients;
  final List<Ingredient> ingredientsFiltered;

  const KitchenStateLoaded(
      {required this.ingredients, required this.ingredientsFiltered});

  @override
  List<Object?> get props => [ingredients,ingredientsFiltered];
}

class KitchenStateError extends KitchenState {
  final String message;
  const KitchenStateError(this.message);

  @override
  List<Object?> get props => [message];
}

//controller for kitchen inventory screen
class KitchenInventoryController extends Cubit<KitchenState> {
  final IKitchenInventoryRepository _kitchenInventoryRepository;
  final IAuthUserService _authUserService;
  List<Ingredient> _ingredients = [];
  List<Ingredient> _ingredientsFiltered = [];

  KitchenInventoryController(
      this._kitchenInventoryRepository, this._authUserService)
      : super(const KitchenStateLoading()) {
    _load();
  }

  Future<void> searchForIngredients(String query) async {
    try {
      final uid = EntityId(_authUserService.currentUser!.uid);
      _ingredientsFiltered =
          await _kitchenInventoryRepository.searchForIngredients(uid, query);

      emit(KitchenStateLoaded(
          ingredients: _ingredients,
          ingredientsFiltered: _ingredientsFiltered));
    } on Exception catch (e) {
      log(e.toString());
      emit(KitchenStateError(e.toString()));
    }
  }

  Future<void> _load() async {
    try {
      final uid = EntityId(_authUserService.currentUser!.uid);
      _ingredients =
          await _kitchenInventoryRepository.getIngredientsAddedByUser(uid);
      _ingredientsFiltered = _ingredients;
      emit(KitchenStateLoaded(
          ingredients: _ingredients,
          ingredientsFiltered: _ingredientsFiltered));
    } on Exception catch (e) {
      log(e.toString());
      emit(KitchenStateError(e.toString()));
    }
  }
}
