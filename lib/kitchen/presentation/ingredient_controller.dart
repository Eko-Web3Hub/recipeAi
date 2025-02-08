import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/kitchen/domain/repositories/kitchen_inventory_repository.dart';

import '../../receipe/domain/model/ingredient.dart';

abstract class IngredientState extends Equatable {}

class IngredientInitialState extends IngredientState {
  @override
  List<Object?> get props => [];
}

class IngredientUpdatedState extends IngredientState {
  IngredientUpdatedState(this.ingredient);

  final Ingredient ingredient;

  @override
  List<Object?> get props => [ingredient];
}

class IngredientController extends Cubit<IngredientState> {
  IngredientController(
    this.ingredient,
    this._kitchenInventoryRepository,
    this._authUserService,
  ) : super(
          IngredientInitialState(),
        );

  final Ingredient ingredient;
  final IKitchenInventoryRepository _kitchenInventoryRepository;
  final IAuthUserService _authUserService;

  Future<void> updateIngredient(String quantity) async {
    final uid = _authUserService.currentUser!.uid;
    final updatedIngredient = ingredient.copy(
      quantity: quantity,
    );

    await _kitchenInventoryRepository.save(uid, updatedIngredient);

    emit(IngredientUpdatedState(updatedIngredient));
  }
}
