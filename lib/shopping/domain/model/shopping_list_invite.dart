import 'package:equatable/equatable.dart';
import 'package:recipe_ai/ddd/entity.dart';

/// An invitation link to a shopping list (`ShoppingListInvites/{token}`).
///
/// The [token] is the secret of the link: anyone signed in who has it can
/// read the invitation and join the list. [listName] and [inviterName] let
/// the invitee see what they join before being a member.
class ShoppingListInvite extends Equatable {
  const ShoppingListInvite({
    required this.token,
    required this.listId,
    required this.listName,
    required this.inviterName,
  });

  final String token;
  final EntityId listId;
  final String listName;
  final String inviterName;

  @override
  List<Object?> get props => [token, listId, listName, inviterName];
}
