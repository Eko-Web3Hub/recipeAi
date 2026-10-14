import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/shopping/domain/model/shopping_item.dart';
import 'package:recipe_ai/shopping/domain/model/shopping_list.dart';
import 'package:recipe_ai/shopping/domain/model/shopping_list_invite.dart';

/// Raised by [IShoppingListRepository.watchList] and
/// [IShoppingListRepository.watchItems] when the user is no longer a member
/// of the list.
class ShoppingListAccessLost implements Exception {
  const ShoppingListAccessLost();
}

abstract class IShoppingListRepository {
  /// The lists [uid] is a member of, most recent date first.
  Stream<List<ShoppingList>> watchLists(EntityId uid);

  /// Creates a list owned by [uid] and returns it.
  Future<ShoppingList> createList(
    EntityId uid,
    String ownerName,
    String name,
    DateTime date,
  );

  /// Saves the name and the date of [list].
  Future<void> updateList(ShoppingList list);

  /// Deletes [list], all its items and its invitation.
  Future<void> deleteList(ShoppingList list);

  /// The list [listId], null once it is deleted. Fails with
  /// [ShoppingListAccessLost] once the user is no longer a member.
  Stream<ShoppingList?> watchList(EntityId listId);

  /// Writes the name of [uid] in [listId] (lists created before
  /// collaboration have none).
  Future<void> ensureMemberName(EntityId listId, EntityId uid, String name);

  /// The token of the invitation link to [list]: the current one, or a new
  /// one.
  Future<String> inviteToken(ShoppingList list, String inviterName);

  /// The invitation [token] points to, null when it no longer exists.
  Future<ShoppingListInvite?> getInvite(String token);

  /// Adds [uid] to the members of the list [invite] points to.
  Future<void> join(ShoppingListInvite invite, EntityId uid, String name);

  /// Takes [uid] out of the members of [listId].
  Future<void> leave(EntityId listId, EntityId uid);

  /// Takes [uid] out of the members of [list] and revokes the invitation
  /// link, so that they cannot join again with it.
  Future<void> removeMember(ShoppingList list, EntityId uid);

  /// The items of [listId], oldest first. Fails with
  /// [ShoppingListAccessLost] once the user is no longer a member.
  Stream<List<ShoppingItem>> watchItems(EntityId listId);

  /// Adds [item] to [listId] and returns it with its generated id.
  Future<ShoppingItem> addItem(EntityId listId, ShoppingItem item);

  Future<void> updateItem(EntityId listId, ShoppingItem item);

  Future<void> removeItem(EntityId listId, EntityId itemId);

  /// Writes back a removed [item] under its former id (undo).
  Future<void> restoreItem(EntityId listId, ShoppingItem item);
}
