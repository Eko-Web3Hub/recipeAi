import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/shopping/domain/model/shopping_item.dart';
import 'package:recipe_ai/shopping/domain/model/shopping_list.dart';
import 'package:recipe_ai/shopping/domain/model/shopping_list_invite.dart';
import 'package:recipe_ai/shopping/domain/repositories/shopping_list_repository.dart';
import 'package:recipe_ai/shopping/infrastructure/serialization/shopping_serialization.dart';

class ShoppingListRepository implements IShoppingListRepository {
  static const String shoppingListsCollection = 'ShoppingLists';
  static const String itemsCollection = 'items';
  static const String invitesCollection = 'ShoppingListInvites';

  /// Firestore refuses batches of more than 500 writes.
  static const int _maxBatchWrites = 450;

  final FirebaseFirestore _firestore;

  ShoppingListRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _lists =>
      _firestore.collection(shoppingListsCollection);

  DocumentReference<Map<String, dynamic>> _list(EntityId listId) =>
      _lists.doc(listId.value);

  CollectionReference<Map<String, dynamic>> _items(EntityId listId) =>
      _list(listId).collection(itemsCollection);

  DocumentReference<Map<String, dynamic>> _invite(String token) =>
      _firestore.collection(invitesCollection).doc(token);

  @override
  Stream<List<ShoppingList>> watchLists(EntityId uid) => _lists
      // Sorted here rather than with orderBy: combined with arrayContains it
      // would need a composite index.
      .where('memberIds', arrayContains: uid.value)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs
                .map(
                  (doc) => ShoppingListSerialization.fromJson(
                    doc.data(),
                    id: doc.id,
                  ),
                )
                .toList()
              ..sort((a, b) => b.date.compareTo(a.date)),
      );

  @override
  Future<ShoppingList> createList(
    EntityId uid,
    String ownerName,
    String name,
    DateTime date,
  ) async {
    final ref = _lists.doc();
    await ref.set(
      ShoppingListSerialization.newListToJson(
        ownerId: uid,
        ownerName: ownerName,
        name: name,
        date: date,
      ),
    );
    return ShoppingList(
      id: EntityId(ref.id),
      name: name,
      date: date,
      ownerId: uid,
      memberIds: [uid],
      memberNames: {uid: ownerName},
    );
  }

  @override
  Future<void> updateList(ShoppingList list) async {
    await _list(list.id).set(
      ShoppingListSerialization.detailsToJson(list),
      SetOptions(merge: true),
    );
    final token = list.inviteToken;
    if (token == null) return;
    try {
      // Keeps the preview of the invitation link up to date.
      await _invite(token).update({'listName': list.name});
    } on FirebaseException catch (error) {
      // The invitation was revoked meanwhile: nothing to update.
      if (error.code != 'not-found') rethrow;
    }
  }

  @override
  Future<void> deleteList(ShoppingList list) async {
    final items = await _items(list.id).get();
    final refs = [
      if (list.inviteToken case final token?) _invite(token),
      ...items.docs.map((doc) => doc.reference),
      // Last: the rules of the items and the invitation read the list.
      _list(list.id),
    ];
    for (var start = 0; start < refs.length; start += _maxBatchWrites) {
      final batch = _firestore.batch();
      for (final ref in refs.skip(start).take(_maxBatchWrites)) {
        batch.delete(ref);
      }
      await batch.commit();
    }
  }

  @override
  Stream<ShoppingList?> watchList(EntityId listId) => _list(listId)
      .snapshots()
      .map((doc) {
        final data = doc.data();
        if (!doc.exists || data == null) return null;
        return ShoppingListSerialization.fromJson(data, id: doc.id);
      })
      .transform(_accessLostOnDenial());

  @override
  Future<void> ensureMemberName(EntityId listId, EntityId uid, String name) =>
      _list(listId).update({
        'members.${uid.value}': ShoppingListSerialization.memberToJson(name),
      });

  @override
  Future<String> inviteToken(ShoppingList list, String inviterName) async {
    if (list.inviteToken case final token?) return token;

    // The id of an auto-generated document: 20 random characters, the
    // secret of the link.
    final invite = _firestore.collection(invitesCollection).doc();
    final batch = _firestore.batch()
      ..set(
        invite,
        ShoppingListInviteSerialization.toJson(
          list: list,
          inviterName: inviterName,
        ),
      )
      ..update(_list(list.id), {
        'inviteToken': invite.id,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    await batch.commit();
    return invite.id;
  }

  @override
  Future<ShoppingListInvite?> getInvite(String token) async {
    final doc = await _invite(token).get();
    final data = doc.data();
    if (!doc.exists || data == null) return null;
    return ShoppingListInviteSerialization.fromJson(data, token: token);
  }

  @override
  Future<void> join(ShoppingListInvite invite, EntityId uid, String name) =>
      _list(invite.listId).update({
        'memberIds': FieldValue.arrayUnion([uid.value]),
        'members.${uid.value}': ShoppingListSerialization.memberToJson(name),
        // Proves to the security rules that the user holds the link.
        'joinToken': invite.token,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  @override
  Future<void> leave(EntityId listId, EntityId uid) =>
      _list(listId).update(_memberRemoval(uid));

  @override
  Future<void> removeMember(ShoppingList list, EntityId uid) async {
    final batch = _firestore.batch()
      ..update(_list(list.id), {
        ..._memberRemoval(uid),
        // A new link will be made on the next invitation.
        'inviteToken': FieldValue.delete(),
      });
    if (list.inviteToken case final token?) batch.delete(_invite(token));
    await batch.commit();
  }

  static Map<String, dynamic> _memberRemoval(EntityId uid) => {
    'memberIds': FieldValue.arrayRemove([uid.value]),
    'members.${uid.value}': FieldValue.delete(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  @override
  Stream<List<ShoppingItem>> watchItems(EntityId listId) => _items(listId)
      .orderBy('date')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) =>
                  ShoppingItemSerialization.fromJson(doc.data(), docId: doc.id),
            )
            .toList(),
      )
      .transform(_accessLostOnDenial());

  /// The security rules refuse the reads of a list the user was removed
  /// from (or left from another device).
  static StreamTransformer<T, T> _accessLostOnDenial<T>() =>
      StreamTransformer.fromHandlers(
        handleError: (error, stackTrace, sink) => sink.addError(
          error is FirebaseException && error.code == 'permission-denied'
              ? const ShoppingListAccessLost()
              : error,
          stackTrace,
        ),
      );

  @override
  Future<ShoppingItem> addItem(EntityId listId, ShoppingItem item) async {
    final ref = _items(listId).doc();
    final added = item.withIngredient(
      item.ingredient.copyWith(id: EntityId(ref.id), date: DateTime.now()),
    );
    await _writeItem(listId, added, countDelta: 1);
    return added;
  }

  @override
  Future<void> updateItem(EntityId listId, ShoppingItem item) => _items(listId)
      .doc(item.id!.value)
      .set(ShoppingItemSerialization.toJson(item), SetOptions(merge: true));

  @override
  Future<void> removeItem(EntityId listId, EntityId itemId) async {
    final batch = _firestore.batch()
      ..delete(_items(listId).doc(itemId.value))
      ..update(_list(listId), _countUpdate(-1));
    await batch.commit();
  }

  @override
  Future<void> restoreItem(EntityId listId, ShoppingItem item) =>
      _writeItem(listId, item, countDelta: 1);

  @override
  Future<void> setChecked(
    EntityId listId,
    EntityId itemId, {
    required bool checked,
    required EntityId uid,
  }) => _items(listId)
      .doc(itemId.value)
      .update(ShoppingItemSerialization.checkedToJson(checked, uid));

  @override
  Future<void> removeItems(EntityId listId, List<EntityId> itemIds) async {
    if (itemIds.isEmpty) return;
    final batch = _firestore.batch();
    for (final itemId in itemIds) {
      batch.delete(_items(listId).doc(itemId.value));
    }
    batch.update(_list(listId), _countUpdate(-itemIds.length));
    await batch.commit();
  }

  @override
  Future<void> restoreItems(EntityId listId, List<ShoppingItem> items) async {
    if (items.isEmpty) return;
    final batch = _firestore.batch();
    for (final item in items) {
      batch.set(
        _items(listId).doc(item.id!.value),
        ShoppingItemSerialization.toJson(item),
      );
    }
    batch.update(_list(listId), _countUpdate(items.length));
    await batch.commit();
  }

  /// Writes [item] and keeps the list's `itemCount` in step, in one batch.
  Future<void> _writeItem(
    EntityId listId,
    ShoppingItem item, {
    required int countDelta,
  }) async {
    final batch = _firestore.batch()
      ..set(
        _items(listId).doc(item.id!.value),
        ShoppingItemSerialization.toJson(item),
      )
      ..update(_list(listId), _countUpdate(countDelta));
    await batch.commit();
  }

  static Map<String, dynamic> _countUpdate(int delta) => {
    'itemCount': FieldValue.increment(delta),
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
