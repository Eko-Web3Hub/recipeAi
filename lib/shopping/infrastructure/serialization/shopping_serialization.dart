import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/fridge/infrastructure/serialization/fridge_item_serialization.dart';
import 'package:recipe_ai/shopping/domain/model/shopping_item.dart';
import 'package:recipe_ai/shopping/domain/model/shopping_list.dart';
import 'package:recipe_ai/shopping/domain/model/shopping_list_invite.dart';

/// Document of `ShoppingLists/{listId}`.
///
/// `members` maps each member uid to `{name}`. `joinToken` is only written
/// by a user joining the list: the security rules check it against the
/// invitations.
abstract class ShoppingListSerialization {
  static ShoppingList fromJson(
    Map<String, dynamic> json, {
    required String id,
  }) {
    final ownerId = json['ownerId'] as String? ?? '';
    final members = json['members'] as Map<String, dynamic>? ?? const {};
    return ShoppingList(
      id: EntityId(id),
      name: json['name'] as String? ?? '',
      date: (json['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ownerId: EntityId(ownerId),
      memberIds: (json['memberIds'] as List<dynamic>? ?? [ownerId])
          .whereType<String>()
          .map(EntityId.new)
          .toList(),
      memberNames: {
        for (final MapEntry(:key, :value) in members.entries)
          if (value case {'name': final String name}) EntityId(key): name,
      },
      inviteToken: json['inviteToken'] as String?,
      itemCount: (json['itemCount'] as num?)?.toInt() ?? 0,
    );
  }

  static Map<String, dynamic> newListToJson({
    required EntityId ownerId,
    required String ownerName,
    required String name,
    required DateTime date,
  }) => {
    'name': name,
    'date': Timestamp.fromDate(date),
    'ownerId': ownerId.value,
    'memberIds': [ownerId.value],
    'members': {ownerId.value: memberToJson(ownerName)},
    'itemCount': 0,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  static Map<String, dynamic> detailsToJson(ShoppingList list) => {
    'name': list.name,
    'date': Timestamp.fromDate(list.date),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  static Map<String, dynamic> memberToJson(String name) => {'name': name};
}

/// Document of `ShoppingListInvites/{token}`.
abstract class ShoppingListInviteSerialization {
  static ShoppingListInvite fromJson(
    Map<String, dynamic> json, {
    required String token,
  }) => ShoppingListInvite(
    token: token,
    listId: EntityId(json['listId'] as String? ?? ''),
    listName: json['listName'] as String? ?? '',
    inviterName: json['inviterName'] as String? ?? '',
  );

  static Map<String, dynamic> toJson({
    required ShoppingList list,
    required String inviterName,
  }) => {
    'listId': list.id.value,
    'listName': list.name,
    'inviterName': inviterName,
    'createdAt': FieldValue.serverTimestamp(),
  };
}

/// Document of `ShoppingLists/{listId}/items/{id}`: the fridge item fields,
/// plus the aisle, the member who added it and whether it is in the cart.
abstract class ShoppingItemSerialization {
  static ShoppingItem fromJson(Map<String, dynamic> json, {String? docId}) {
    final addedBy = json['addedBy'] as String?;
    final checkedBy = json['checkedBy'] as String?;
    return ShoppingItem(
      ingredient: FridgeItemSerialization.fromJson(json, docId: docId),
      categoryId: json['categoryId'] as String?,
      addedBy: addedBy == null ? null : EntityId(addedBy),
      checked: json['checked'] == true,
      checkedBy: checkedBy == null ? null : EntityId(checkedBy),
    );
  }

  static Map<String, dynamic> toJson(ShoppingItem item) => {
    ...FridgeItemSerialization.toJson(item.ingredient),
    'categoryId': item.categoryId,
    'addedBy': item.addedBy?.value,
    ...checkedToJson(item.checked, item.checkedBy),
  };

  static Map<String, dynamic> checkedToJson(bool checked, EntityId? by) => {
    'checked': checked,
    'checkedBy': checked ? by?.value : null,
  };
}
