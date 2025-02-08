import 'package:flutter_bloc/flutter_bloc.dart';

abstract class IngredientState {}

class IngredientInitialState extends IngredientState {}

class IngredientUpdatedState extends IngredientState {}

class IngredientController extends Cubit<IngredientState> {
  IngredientController() : super(IngredientInitialState());

  Future<void> updateIngredient(int quantity) async {
    emit(IngredientInitialState());
  }
}
