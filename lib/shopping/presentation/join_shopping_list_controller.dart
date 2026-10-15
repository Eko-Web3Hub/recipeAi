import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/application/user_personnal_info_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/shopping/application/member_name.dart';
import 'package:recipe_ai/shopping/domain/model/shopping_list_invite.dart';
import 'package:recipe_ai/shopping/domain/repositories/shopping_list_repository.dart';
import 'package:recipe_ai/utils/safe_emit.dart';

/// [invalid]: the link was revoked or never existed. [joined]: the user is
/// a member, [JoinShoppingListState.invite] tells which list to open.
enum JoinShoppingListStatus { loading, ready, joining, joined, invalid, error }

final class JoinShoppingListState extends Equatable {
  const JoinShoppingListState({
    this.status = JoinShoppingListStatus.loading,
    this.invite,
  });

  final JoinShoppingListStatus status;
  final ShoppingListInvite? invite;

  @override
  List<Object?> get props => [status, invite];
}

/// The screen an invitation link opens: shows the invitation, then joins
/// the list.
class JoinShoppingListController extends Cubit<JoinShoppingListState> {
  JoinShoppingListController(
    this._token,
    this._repository,
    this._authUserService,
    this._userPersonnalInfoService,
  ) : super(const JoinShoppingListState()) {
    _load();
  }

  final String _token;
  final IShoppingListRepository _repository;
  final IAuthUserService _authUserService;
  final IUserPersonnalInfoService _userPersonnalInfoService;

  EntityId get _uid => _authUserService.currentUser!.uid;

  Future<void> _load() async {
    try {
      final invite = await _repository.getInvite(_token);
      if (invite == null) {
        safeEmit(
          const JoinShoppingListState(status: JoinShoppingListStatus.invalid),
        );
        return;
      }
      final lists = await _repository.watchLists(_uid).first;
      final isMember = lists.any((list) => list.id == invite.listId);
      safeEmit(
        JoinShoppingListState(
          status: isMember
              ? JoinShoppingListStatus.joined
              : JoinShoppingListStatus.ready,
          invite: invite,
        ),
      );
    } catch (error) {
      log('Shopping list invitation failed to load: $error');
      safeEmit(
        const JoinShoppingListState(status: JoinShoppingListStatus.error),
      );
    }
  }

  Future<void> join() async {
    final invite = state.invite;
    if (invite == null || state.status != JoinShoppingListStatus.ready) {
      return;
    }
    safeEmit(
      JoinShoppingListState(
        status: JoinShoppingListStatus.joining,
        invite: invite,
      ),
    );
    try {
      await _repository.join(
        invite,
        _uid,
        await currentMemberName(_userPersonnalInfoService),
      );
      safeEmit(
        JoinShoppingListState(
          status: JoinShoppingListStatus.joined,
          invite: invite,
        ),
      );
    } catch (error) {
      // Mostly a link revoked between the preview and the tap.
      log('Shopping list join failed: $error');
      safeEmit(
        const JoinShoppingListState(status: JoinShoppingListStatus.invalid),
      );
    }
  }
}
