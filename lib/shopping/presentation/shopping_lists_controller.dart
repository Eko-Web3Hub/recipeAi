import 'dart:async';
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/application/user_personnal_info_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/shopping/application/member_name.dart';
import 'package:recipe_ai/shopping/domain/model/shopping_list.dart';
import 'package:recipe_ai/shopping/domain/repositories/shopping_list_repository.dart';
import 'package:recipe_ai/utils/safe_emit.dart';

enum ShoppingListsStatus { loading, loaded, error }

final class ShoppingListsState extends Equatable {
  const ShoppingListsState({
    this.status = ShoppingListsStatus.loading,
    this.lists = const [],
    this.errorCount = 0,
  });

  final ShoppingListsStatus status;
  final List<ShoppingList> lists;

  /// Bumped on every failed write: the screen shows an error snack bar.
  final int errorCount;

  ShoppingListsState copyWith({
    ShoppingListsStatus? status,
    List<ShoppingList>? lists,
    int? errorCount,
  }) => ShoppingListsState(
    status: status ?? this.status,
    lists: lists ?? this.lists,
    errorCount: errorCount ?? this.errorCount,
  );

  @override
  List<Object?> get props => [status, lists, errorCount];
}

/// "Mes listes de courses": every list the user is a member of.
class ShoppingListsController extends Cubit<ShoppingListsState> {
  ShoppingListsController(
    this._repository,
    this._authUserService,
    this._userPersonnalInfoService,
  ) : super(const ShoppingListsState()) {
    _subscription = _repository
        .watchLists(_uid)
        .listen(
          (lists) => safeEmit(
            state.copyWith(status: ShoppingListsStatus.loaded, lists: lists),
          ),
          onError: (Object error) {
            log('Shopping lists failed to load: $error');
            safeEmit(state.copyWith(status: ShoppingListsStatus.error));
          },
        );
  }

  final IShoppingListRepository _repository;
  final IAuthUserService _authUserService;
  final IUserPersonnalInfoService _userPersonnalInfoService;
  StreamSubscription<List<ShoppingList>>? _subscription;

  EntityId get _uid => _authUserService.currentUser!.uid;

  /// Creates a list and returns it, null when it failed.
  Future<ShoppingList?> create(String name, DateTime date) async {
    try {
      return await _repository.createList(
        _uid,
        await currentMemberName(_userPersonnalInfoService),
        name.trim(),
        date,
      );
    } catch (error) {
      log('Shopping list creation failed: $error');
      _failed();
      return null;
    }
  }

  Future<void> update(ShoppingList list, String name, DateTime date) async {
    try {
      await _repository.updateList(
        list.copyWith(name: name.trim(), date: date),
      );
    } catch (error) {
      log('Shopping list update failed: $error');
      _failed();
    }
  }

  /// Deletes [list] for every member. Only its owner can.
  Future<void> delete(ShoppingList list) async {
    try {
      await _repository.deleteList(list);
    } catch (error) {
      log('Shopping list deletion failed: $error');
      _failed();
    }
  }

  /// Takes the user out of a list shared with them.
  Future<void> leave(ShoppingList list) async {
    try {
      await _repository.leave(list.id, _uid);
    } catch (error) {
      log('Shopping list leave failed: $error');
      _failed();
    }
  }

  bool isOwner(ShoppingList list) => list.isOwnedBy(_uid);

  void _failed() => safeEmit(state.copyWith(errorCount: state.errorCount + 1));

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
