import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';

abstract class ReceiptTicketScanResultState extends Equatable {}

class ReceiptTicketScanResultInitial extends ReceiptTicketScanResultState {
  @override
  List<Object?> get props => [];
}

class ReceiptTicketUpdateIngredientSuccess
    extends ReceiptTicketScanResultState {
  final List<Ingredient> ingredients;

  ReceiptTicketUpdateIngredientSuccess({
    required this.ingredients,
  });

  @override
  List<Object?> get props => [ingredients];
}

class ReceiptTicketScanResultController
    extends Cubit<ReceiptTicketScanResultState> {
  ReceiptTicketScanResultController({
    required this.ingredients,
  }) : super(
          ReceiptTicketScanResultInitial(),
        );

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
      ReceiptTicketUpdateIngredientSuccess(
        ingredients: updatedIngredients,
      ),
    );
  }

  List<Ingredient> ingredients;
}
