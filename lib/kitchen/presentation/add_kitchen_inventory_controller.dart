import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/kitchen/domain/repositories/kitchen_inventory_repository.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';

abstract class AddKitchenState extends Equatable {}

class AddKitchenSuccess extends AddKitchenState {
  @override
  List<Object?> get props => [];
}

class AddKitchenFailed extends AddKitchenState {
  final String? message;

  AddKitchenFailed({
    required this.message,
  });
  @override
  List<Object?> get props => [message];
}

class AddKitchenInventoryController extends Cubit<AddKitchenState?> {
  AddKitchenInventoryController(
    this._kitchenInventoryRepository,
    this._authUserService,
  ) : super(null);

  final IKitchenInventoryRepository _kitchenInventoryRepository;
  final IAuthUserService _authUserService;

  Future<void> addKitchenInventory({
    required String name,
    required String quantity,
    required DateTime timestamp,
  }) async {
    try {
      final uid = _authUserService.currentUser!.uid;
      await _kitchenInventoryRepository.addIngredient(
        uid,
        Ingredient(
          name: name,
          quantity: quantity,
          date: timestamp,
          id: null,
        ),
      );

      emit(AddKitchenSuccess());
    } on Exception catch (e) {
      emit(
        AddKitchenFailed(
          message: e.toString(),
        ),
      );
    }
  }
}
