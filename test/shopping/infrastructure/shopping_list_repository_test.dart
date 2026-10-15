import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/fridge/domain/model/fridge_item.dart';
import 'package:recipe_ai/fridge/domain/model/fridge_unit.dart';
import 'package:recipe_ai/shopping/domain/model/shopping_item.dart';
import 'package:recipe_ai/shopping/infrastructure/shopping_list_repository.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late ShoppingListRepository repository;

  const uid = EntityId('uid');
  const otherUid = EntityId('other');

  final tomatoes = ShoppingItem(
    ingredient: FridgeItem.draft(
      name: 'Tomatoes',
      nameFr: 'Tomates',
      amount: 1,
      unit: FridgeUnit.kg,
      catalogId: 'tomato',
    ),
    categoryId: 'veg',
    addedBy: uid,
  );

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = ShoppingListRepository(firestore: firestore);
  });

  Future<Map<String, dynamic>> listDoc(EntityId listId) async {
    final doc = await firestore
        .collection(ShoppingListRepository.shoppingListsCollection)
        .doc(listId.value)
        .get();
    return doc.data()!;
  }

  test('lists only the lists of the member, most recent first', () async {
    await repository.createList(uid, 'Ana', 'Week', DateTime(2026, 10, 12));
    await repository.createList(uid, 'Ana', 'Party', DateTime(2026, 10, 20));
    await repository.createList(otherUid, 'Bob', 'No', DateTime(2026, 10, 14));

    final lists = await repository.watchLists(uid).first;

    expect(lists.map((list) => list.name), ['Party', 'Week']);
    expect(lists.first.memberIds, [uid]);
    expect(lists.first.ownerId, uid);
    expect(lists.first.memberNames, {uid: 'Ana'});
  });

  test('reads a list created before collaboration', () async {
    await firestore
        .collection(ShoppingListRepository.shoppingListsCollection)
        .doc('old')
        .set({
          'name': 'Old',
          'ownerId': uid.value,
          'memberIds': [uid.value],
        });

    final list = await repository.watchList(const EntityId('old')).first;

    expect(list!.memberNames, isEmpty);
    expect(list.inviteToken, isNull);

    await repository.ensureMemberName(list.id, uid, 'Ana');
    final named = await repository.watchList(list.id).first;
    expect(named!.memberNames, {uid: 'Ana'});
  });

  test('updates the name and the date of a list', () async {
    final list = await repository.createList(
      uid,
      'Ana',
      'Week',
      DateTime(2026, 10),
    );

    await repository.updateList(
      list.copyWith(name: 'Weekend', date: DateTime(2026, 10, 18)),
    );

    final saved = await repository.watchList(list.id).first;
    expect(saved!.name, 'Weekend');
    expect(saved.date, DateTime(2026, 10, 18));
  });

  test('adds, updates and removes items, keeping the item count', () async {
    final list = await repository.createList(
      uid,
      'Ana',
      'Week',
      DateTime(2026, 10),
    );

    final added = await repository.addItem(list.id, tomatoes);
    expect(added.id, isNotNull);
    expect((await listDoc(list.id))['itemCount'], 1);

    await repository.updateItem(
      list.id,
      added.withIngredient(added.ingredient.copyWith(amount: () => 2)),
    );
    final items = await repository.watchItems(list.id).first;
    expect(items.single.ingredient.amount, 2);
    expect(items.single.categoryId, 'veg');
    expect(items.single.addedBy, uid);
    expect(items.single.ingredient.catalogId, 'tomato');

    await repository.removeItem(list.id, added.id!);
    expect(await repository.watchItems(list.id).first, isEmpty);
    expect((await listDoc(list.id))['itemCount'], 0);

    await repository.restoreItem(list.id, added);
    final restored = await repository.watchItems(list.id).first;
    expect(restored.single.id, added.id);
    expect((await listDoc(list.id))['itemCount'], 1);
  });

  test('checks items, then removes and restores them at once', () async {
    final list = await repository.createList(
      uid,
      'Ana',
      'Week',
      DateTime(2026, 10),
    );
    final first = await repository.addItem(list.id, tomatoes);
    final second = await repository.addItem(
      list.id,
      ShoppingItem(ingredient: FridgeItem.draft(name: 'Rice')),
    );

    await repository.setChecked(list.id, first.id!, checked: true, uid: uid);
    var items = await repository.watchItems(list.id).first;
    expect(items.first.checked, isTrue);
    expect(items.first.checkedBy, uid);
    expect(items.last.checked, isFalse);

    await repository.setChecked(list.id, first.id!, checked: false, uid: uid);
    items = await repository.watchItems(list.id).first;
    expect(items.first.checked, isFalse);
    expect(items.first.checkedBy, isNull);

    await repository.removeItems(list.id, [first.id!, second.id!]);
    expect(await repository.watchItems(list.id).first, isEmpty);
    expect((await listDoc(list.id))['itemCount'], 0);

    final checked = first.withChecked(true, by: uid);
    await repository.restoreItems(list.id, [checked, second]);
    items = await repository.watchItems(list.id).first;
    expect(items.map((item) => item.id), [first.id, second.id]);
    expect(items.first.checked, isTrue);
    expect((await listDoc(list.id))['itemCount'], 2);
  });

  group('collaboration', () {
    test('an invitation link lets another user join the list', () async {
      final list = await repository.createList(
        uid,
        'Ana',
        'Week',
        DateTime(2026, 10),
      );

      final token = await repository.inviteToken(list, 'Ana');
      final invite = await repository.getInvite(token);
      expect(invite!.listId, list.id);
      expect(invite.listName, 'Week');
      expect(invite.inviterName, 'Ana');

      await repository.join(invite, otherUid, 'Bob');

      final joined = await repository.watchList(list.id).first;
      expect(joined!.memberIds, [uid, otherUid]);
      expect(joined.memberNames, {uid: 'Ana', otherUid: 'Bob'});
      expect(joined.inviteToken, token);
      expect((await listDoc(list.id))['joinToken'], token);
      expect(await repository.watchLists(otherUid).first, [joined]);
    });

    test('the same link is shared until a member is removed', () async {
      final list = await repository.createList(
        uid,
        'Ana',
        'Week',
        DateTime(2026, 10),
      );
      final token = await repository.inviteToken(list, 'Ana');
      await repository.join(
        (await repository.getInvite(token))!,
        otherUid,
        'Bob',
      );
      final shared = (await repository.watchList(list.id).first)!;

      expect(await repository.inviteToken(shared, 'Ana'), token);

      await repository.removeMember(shared, otherUid);

      final afterRemoval = (await repository.watchList(list.id).first)!;
      expect(afterRemoval.memberIds, [uid]);
      expect(afterRemoval.memberNames, {uid: 'Ana'});
      expect(afterRemoval.inviteToken, isNull);
      expect(await repository.getInvite(token), isNull);
      expect(await repository.inviteToken(afterRemoval, 'Ana'), isNot(token));
    });

    test('a member leaves the list', () async {
      final list = await repository.createList(
        uid,
        'Ana',
        'Week',
        DateTime(2026, 10),
      );
      final token = await repository.inviteToken(list, 'Ana');
      await repository.join(
        (await repository.getInvite(token))!,
        otherUid,
        'Bob',
      );

      await repository.leave(list.id, otherUid);

      final left = (await repository.watchList(list.id).first)!;
      expect(left.memberIds, [uid]);
      expect(left.memberNames, {uid: 'Ana'});
      expect(await repository.watchLists(otherUid).first, isEmpty);
    });

    test('renaming the list updates the invitation preview', () async {
      final list = await repository.createList(
        uid,
        'Ana',
        'Week',
        DateTime(2026, 10),
      );
      final token = await repository.inviteToken(list, 'Ana');
      final shared = (await repository.watchList(list.id).first)!;

      await repository.updateList(shared.copyWith(name: 'Weekend'));

      expect((await repository.getInvite(token))!.listName, 'Weekend');
    });
  });

  test('deleting a list deletes its items and its invitation', () async {
    final list = await repository.createList(
      uid,
      'Ana',
      'Week',
      DateTime(2026, 10),
    );
    await repository.addItem(list.id, tomatoes);
    final token = await repository.inviteToken(list, 'Ana');
    final shared = (await repository.watchList(list.id).first)!;

    await repository.deleteList(shared);

    expect(await repository.watchList(list.id).first, isNull);
    expect(await repository.watchItems(list.id).first, isEmpty);
    expect(await repository.watchLists(uid).first, isEmpty);
    expect(await repository.getInvite(token), isNull);
  });
}
