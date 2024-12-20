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
  const KitchenStateLoaded(this.ingredients);

  @override
  List<Object?> get props => [ingredients];
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

  KitchenInventoryController(
      this._kitchenInventoryRepository, this._authUserService)
      : super(const KitchenStateLoading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final uid = EntityId(_authUserService.currentUser!.uid);
      final ingredients =
          await _kitchenInventoryRepository.getIngredientsAddedByUser(uid);
      emit(KitchenStateLoaded(ingredients));
    } on Exception catch (e) {
      log(e.toString());
      emit(KitchenStateError(e.toString()));
    }
  }
}
