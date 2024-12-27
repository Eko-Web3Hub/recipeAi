import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';

import '../../kitchen/domain/repositories/kitchen_inventory_repository.dart';

abstract class ReceiptTicketScanResultState extends Equatable {}

class ReceiptTicketScanResultInitial extends ReceiptTicketScanResultState {
  @override
  List<Object?> get props => [];
}

class ReceiptTicketScanUpdateIngredientSuccess
    extends ReceiptTicketScanResultState {
  final List<Ingredient> ingredients;

  ReceiptTicketScanUpdateIngredientSuccess({
    required this.ingredients,
  });

  @override
  List<Object?> get props => [ingredients];
}

class ReceiptTicketScanUpdateKitechenInventorySuccess
    extends ReceiptTicketScanResultState {
  @override
  List<Object?> get props => [];
}

class ReceiptTicketScanResultController
    extends Cubit<ReceiptTicketScanResultState> {
  ReceiptTicketScanResultController(
    this._kitchenInventoryRepository,
    this._authUserService, {
    required this.ingredients,
  }) : super(
          ReceiptTicketScanResultInitial(),
        );

  void removeIngredient(int index) {
    final updatedIngredients = ingredients
        .where((ingredient) => ingredients.indexOf(ingredient) != index)
        .toList();
    ingredients = updatedIngredients;

    emit(
      ReceiptTicketScanUpdateIngredientSuccess(
        ingredients: updatedIngredients,
      ),
    );
  }

  void updateIngredient(
    int index,
    int newQuantity,
  ) {
    final updatedIngredients = ingredients.map((ingredient) {
      if (ingredients.indexOf(ingredient) == index) {
        return ingredient.copy(
          quantity: newQuantity.toString(),
        );
      }
      return ingredient;
    }).toList();
    ingredients = updatedIngredients;

    emit(
      ReceiptTicketScanUpdateIngredientSuccess(
        ingredients: updatedIngredients,
      ),
    );
  }

  void addIngredientsToKitchenInventory() async {
    await Future.wait(ingredients
        .map(
          (ingredient) => _kitchenInventoryRepository.save(
            _authUserService.currentUser!.uid,
            ingredient.date != null
                ? ingredient
                : ingredient.copy(
                    date: DateTime.now(),
                  ),
          ),
        )
        .toList());
    emit(
      ReceiptTicketScanUpdateKitechenInventorySuccess(),
    );
  }

  List<Ingredient> ingredients;
  final IKitchenInventoryRepository _kitchenInventoryRepository;
  final IAuthUserService _authUserService;
}
