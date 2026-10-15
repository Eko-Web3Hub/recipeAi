import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/application/user_personnal_info_service.dart';
import 'package:recipe_ai/auth/domain/model/user_personnal_info.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/fridge/application/fridge_stock_service.dart';
import 'package:recipe_ai/fridge/domain/fridge_quantity.dart';
import 'package:recipe_ai/fridge/domain/model/catalog_category.dart';
import 'package:recipe_ai/fridge/domain/model/catalog_ingredient.dart';
import 'package:recipe_ai/fridge/domain/model/fridge_item.dart';
import 'package:recipe_ai/fridge/domain/model/fridge_unit.dart';
import 'package:recipe_ai/fridge/domain/repositories/fridge_repository.dart';
import 'package:recipe_ai/shopping/domain/model/shopping_item.dart';
import 'package:recipe_ai/shopping/domain/model/shopping_list.dart';
import 'package:recipe_ai/shopping/domain/repositories/shopping_list_repository.dart';
import 'package:recipe_ai/shopping/presentation/shopping_list_controller.dart';

class ShoppingListRepositoryMock extends Mock
    implements IShoppingListRepository {}

class IngredientCatalogRepositoryMock extends Mock
    implements IIngredientCatalogRepository {}

class FridgeRepositoryMock extends Mock implements IFridgeRepository {}

class FridgeStockServiceMock extends Mock implements FridgeStockService {}

class AuthUserServiceMock extends Mock implements IAuthUserService {}

class UserPersonnalInfoServiceMock extends Mock
    implements IUserPersonnalInfoService {}

void main() {
  late IShoppingListRepository repository;
  late IIngredientCatalogRepository catalogRepository;
  late IFridgeRepository fridgeRepository;
  late FridgeStockService stockService;
  late IAuthUserService authUserService;
  late IUserPersonnalInfoService userPersonnalInfoService;
  late StreamController<ShoppingList?> list;
  late StreamController<List<ShoppingItem>> items;

  const uid = EntityId('uid');
  const listId = EntityId('list');
  const authUser = AuthUser(uid: uid, email: 'email@gmail.com');

  final shoppingList = ShoppingList(
    id: listId,
    name: 'Week',
    date: DateTime(2026, 10, 14),
    ownerId: uid,
    memberIds: const [uid],
    memberNames: {uid: 'Ana'},
  );

  const vegetables = CatalogCategory(id: 'veg', name: 'Vegetables');
  const catalog = [
    CatalogIngredient(
      id: 'tomato',
      name: 'Tomatoes',
      nameFr: 'Tomates',
      defaultUnit: FridgeUnit.kg,
      defaultAmount: 1,
      categoryId: 'veg',
    ),
  ];

  final tomatoes = ShoppingItem(
    ingredient: FridgeItem.draft(
      name: 'Tomatoes',
      nameFr: 'Tomates',
      amount: 1,
      unit: FridgeUnit.kg,
      catalogId: 'tomato',
    ).copyWith(id: const EntityId('t1')),
    categoryId: 'veg',
    addedBy: uid,
  );

  setUpAll(() {
    registerFallbackValue(const EntityId('fallback'));
    registerFallbackValue(shoppingList);
    registerFallbackValue(<EntityId>[]);
    registerFallbackValue(<ShoppingItem>[]);
    registerFallbackValue(FridgeItem.draft(name: 'fallback'));
    registerFallbackValue(
      ShoppingItem(ingredient: FridgeItem.draft(name: 'fallback')),
    );
    registerFallbackValue(
      FridgeStockChange(result: FridgeItem.draft(name: 'fallback')),
    );
  });

  setUp(() {
    repository = ShoppingListRepositoryMock();
    catalogRepository = IngredientCatalogRepositoryMock();
    fridgeRepository = FridgeRepositoryMock();
    stockService = FridgeStockServiceMock();
    authUserService = AuthUserServiceMock();
    userPersonnalInfoService = UserPersonnalInfoServiceMock();
    when(
      () => userPersonnalInfoService.get(),
    ).thenAnswer((_) async => const UserPersonnalInfo(uid: uid, name: 'Ana'));
    when(
      () => repository.ensureMemberName(listId, uid, any()),
    ).thenAnswer((_) async {});
    list = StreamController<ShoppingList?>();
    items = StreamController<List<ShoppingItem>>();

    when(() => authUserService.currentUser).thenReturn(authUser);
    when(() => repository.watchList(listId)).thenAnswer((_) => list.stream);
    when(() => repository.watchItems(listId)).thenAnswer((_) => items.stream);
    when(
      () => fridgeRepository.watchUsuals(uid),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => catalogRepository.loadCatalog(),
    ).thenAnswer((_) async => catalog);
    when(
      () => catalogRepository.loadCategories(),
    ).thenAnswer((_) async => const [vegetables]);
    when(() => repository.addItem(listId, any())).thenAnswer((
      invocation,
    ) async {
      final item = invocation.positionalArguments[1] as ShoppingItem;
      return item.withIngredient(
        item.ingredient.copyWith(id: const EntityId('new')),
      );
    });
    when(() => repository.updateItem(listId, any())).thenAnswer((_) async {});
    when(() => repository.removeItem(listId, any())).thenAnswer((_) async {});
    when(() => repository.restoreItem(listId, any())).thenAnswer((_) async {});
    when(() => stockService.undo(uid, any())).thenAnswer((_) async {});
  });

  tearDown(() async {
    await list.close();
    await items.close();
  });

  Future<ShoppingListController> sut({
    List<ShoppingItem> initial = const [],
    ShoppingList? listValue,
  }) async {
    final controller = ShoppingListController(
      listId,
      repository,
      catalogRepository,
      fridgeRepository,
      stockService,
      authUserService,
      userPersonnalInfoService,
    );
    list.add(listValue ?? shoppingList);
    items.add(initial);
    await pumpEventQueue();
    return controller;
  }

  group('loading', () {
    test('emits the list, its items and their aisles', () async {
      final custom = ShoppingItem(
        ingredient: FridgeItem.draft(
          name: 'Sauce',
        ).copyWith(id: const EntityId('s1')),
      );
      final controller = await sut(initial: [custom, tomatoes]);

      expect(controller.state.status, ShoppingListStatus.loaded);
      expect(controller.state.list, shoppingList);
      expect(controller.state.sections.map((s) => s.category), [
        vegetables,
        null,
      ]);
      await controller.close();
    });

    test('goes to removed when the user is no longer a member', () async {
      final controller = await sut();
      list.addError(const ShoppingListAccessLost());
      items.addError(const ShoppingListAccessLost());
      await pumpEventQueue();

      expect(controller.state.status, ShoppingListStatus.removed);
      await controller.close();
    });

    test('goes to deleted when the list disappears', () async {
      final controller = await sut();
      list.add(null);
      await pumpEventQueue();

      expect(controller.state.status, ShoppingListStatus.deleted);
      await controller.close();
    });
  });

  group('add', () {
    test('adds a new item in the aisle of its catalog category', () async {
      final controller = await sut();

      await controller.add(
        FridgeItem.draft(
          name: 'Tomatoes',
          amount: 2,
          unit: FridgeUnit.kg,
          catalogId: 'tomato',
        ),
      );

      final added =
          verify(() => repository.addItem(listId, captureAny())).captured.single
              as ShoppingItem;
      expect(added.categoryId, 'veg');
      expect(added.addedBy, uid);
      expect(controller.state.highlightedId, 'new');
      await controller.close();
    });

    test('merges into the same ingredient already in the list', () async {
      final controller = await sut(initial: [tomatoes]);

      await controller.add(
        FridgeItem.draft(name: 'Tomates', amount: 500, unit: FridgeUnit.g),
      );

      final saved =
          verify(
                () => repository.updateItem(listId, captureAny()),
              ).captured.single
              as ShoppingItem;
      expect(saved.id, tomatoes.id);
      expect(saved.ingredient.amount, 1.5);
      expect(
        controller.state.feedback,
        isA<ShoppingItemMergedFeedback>().having(
          (f) => f.outcome,
          'outcome',
          MergeOutcome.total,
        ),
      );
      verifyNever(() => repository.addItem(listId, any()));
      await controller.close();
    });

    test('flags the suggestions already in the list', () async {
      final controller = await sut(initial: [tomatoes]);

      controller.onQueryChanged('tomat');

      expect(controller.state.suggestions.first.isAlreadyAdded, isTrue);
      await controller.close();
    });
  });

  group('remove', () {
    test('remove then undo restores the same item', () async {
      final controller = await sut(initial: [tomatoes]);

      await controller.remove(tomatoes);
      verify(() => repository.removeItem(listId, tomatoes.id!)).called(1);
      expect(controller.state.feedback, isA<ShoppingItemRemovedFeedback>());

      await controller.undoRemove(tomatoes);
      verify(() => repository.restoreItem(listId, tomatoes)).called(1);
      await controller.close();
    });
  });

  group('cart', () {
    final checkedTomatoes = tomatoes.withChecked(true, by: uid);
    final rice = ShoppingItem(
      ingredient: FridgeItem.draft(
        name: 'Rice',
        amount: 500,
        unit: FridgeUnit.g,
      ).copyWith(id: const EntityId('r1')),
      checked: true,
      checkedBy: uid,
    );
    final tomatoChange = FridgeStockChange(
      result: tomatoes.fridgeDraft.copyWith(id: const EntityId('f1')),
    );
    final riceChange = FridgeStockChange(
      result: rice.fridgeDraft.copyWith(id: const EntityId('f2')),
    );

    setUp(() {
      when(
        () => repository.setChecked(
          listId,
          any(),
          checked: any(named: 'checked'),
          uid: uid,
        ),
      ).thenAnswer((_) async {});
      when(
        () => repository.removeItems(listId, any()),
      ).thenAnswer((_) async {});
      when(
        () => repository.restoreItems(listId, any()),
      ).thenAnswer((_) async {});
      when(() => stockService.addOrMerge(uid, any())).thenAnswer((invocation) {
        final draft = invocation.positionalArguments[1] as FridgeItem;
        return Future.value(draft.name == 'Rice' ? riceChange : tomatoChange);
      });
    });

    test('checking an item keeps it in the list, in the cart', () async {
      final controller = await sut(initial: [tomatoes]);

      await controller.toggleChecked(tomatoes);
      verify(
        () => repository.setChecked(
          listId,
          tomatoes.id!,
          checked: true,
          uid: uid,
        ),
      ).called(1);

      await controller.toggleChecked(checkedTomatoes);
      verify(
        () => repository.setChecked(
          listId,
          tomatoes.id!,
          checked: false,
          uid: uid,
        ),
      ).called(1);
      verifyNever(() => stockService.addOrMerge(uid, any()));
      await controller.close();
    });

    test('checked items leave the aisles for "déjà acheté"', () async {
      final controller = await sut(initial: [checkedTomatoes, rice]);

      expect(controller.state.sections, isEmpty);
      expect(controller.state.checkedItems, [checkedTomatoes, rice]);
      await controller.close();
    });

    test('a checked item is not merged with a new one', () async {
      final controller = await sut(initial: [checkedTomatoes]);

      expect(controller.existingFor(tomatoes.fridgeDraft), isNull);
      await controller.close();
    });

    test(
      'moves the checked items to the fridge, then out of the list',
      () async {
        final controller = await sut(initial: [checkedTomatoes, rice]);

        await controller.moveCheckedToFridge();

        final drafts = verify(
          () => stockService.addOrMerge(uid, captureAny()),
        ).captured.cast<FridgeItem>();
        expect(drafts.map((draft) => draft.name), ['Tomatoes', 'Rice']);
        expect(drafts.every((draft) => draft.id == null), isTrue);
        verify(
          () => repository.removeItems(listId, [tomatoes.id!, rice.id!]),
        ).called(1);
        expect(
          controller.state.feedback,
          isA<ShoppingItemsMovedToFridgeFeedback>().having(
            (f) => f.changes,
            'changes',
            [tomatoChange, riceChange],
          ),
        );
        expect(controller.state.isMovingToFridge, isFalse);
        await controller.close();
      },
    );

    test('only the checked items go to the fridge', () async {
      final controller = await sut(initial: [tomatoes, rice]);

      await controller.moveCheckedToFridge();

      verify(() => stockService.addOrMerge(uid, any())).called(1);
      verify(() => repository.removeItems(listId, [rice.id!])).called(1);
      await controller.close();
    });

    test('undo takes them out of the fridge and back in the cart', () async {
      final controller = await sut();

      await controller.undoMoveToFridge(
        [checkedTomatoes, rice],
        [tomatoChange, riceChange],
      );

      verifyInOrder([
        () => stockService.undo(uid, riceChange),
        () => stockService.undo(uid, tomatoChange),
        () => repository.restoreItems(listId, [checkedTomatoes, rice]),
      ]);
      await controller.close();
    });

    test('all or nothing: a failure undoes the fridge changes', () async {
      when(() => stockService.addOrMerge(uid, any())).thenAnswer((invocation) {
        final draft = invocation.positionalArguments[1] as FridgeItem;
        if (draft.name == 'Rice') throw Exception('offline');
        return Future.value(tomatoChange);
      });
      final controller = await sut(initial: [checkedTomatoes, rice]);

      await controller.moveCheckedToFridge();

      verify(() => stockService.undo(uid, tomatoChange)).called(1);
      verifyNever(() => repository.removeItems(listId, any()));
      expect(controller.state.feedback, isA<ShoppingListErrorFeedback>());
      expect(controller.state.isMovingToFridge, isFalse);
      await controller.close();
    });

    test('the list write failing undoes the fridge changes', () async {
      when(
        () => repository.removeItems(listId, any()),
      ).thenThrow(Exception('offline'));
      final controller = await sut(initial: [checkedTomatoes, rice]);

      await controller.moveCheckedToFridge();

      verify(() => stockService.undo(uid, riceChange)).called(1);
      verify(() => stockService.undo(uid, tomatoChange)).called(1);
      expect(controller.state.feedback, isA<ShoppingListErrorFeedback>());
      await controller.close();
    });

    test('a second tap while moving does not move twice', () async {
      final pending = Completer<FridgeStockChange>();
      when(
        () => stockService.addOrMerge(uid, any()),
      ).thenAnswer((_) => pending.future);
      final controller = await sut(initial: [checkedTomatoes]);

      final first = controller.moveCheckedToFridge();
      await controller.moveCheckedToFridge();
      pending.complete(tomatoChange);
      await first;

      verify(() => stockService.addOrMerge(uid, any())).called(1);
      await controller.close();
    });
  });

  group('members', () {
    const otherUid = EntityId('other');
    final shared = ShoppingList(
      id: listId,
      name: 'Week',
      date: DateTime(2026, 10, 14),
      ownerId: uid,
      memberIds: const [uid, otherUid],
      memberNames: {uid: 'Ana', otherUid: 'Bob'},
      inviteToken: 'token',
    );

    test('writes the user name when the list misses it', () async {
      final controller = await sut(
        listValue: ShoppingList(
          id: listId,
          name: 'Old',
          date: DateTime(2026),
          ownerId: uid,
          memberIds: const [uid],
        ),
      );
      await pumpEventQueue();

      verify(() => repository.ensureMemberName(listId, uid, 'Ana')).called(1);
      await controller.close();
    });

    test('does not write the user name when the list has it', () async {
      final controller = await sut();
      await pumpEventQueue();

      verifyNever(() => repository.ensureMemberName(listId, uid, any()));
      await controller.close();
    });

    test('invite returns the link of the invitation', () async {
      when(
        () => repository.inviteToken(shared, 'Ana'),
      ).thenAnswer((_) async => 'token');
      final controller = await sut(listValue: shared);

      expect(
        await controller.invite(),
        'https://recipe-ai-5e261.web.app/shopping-lists/join/token',
      );
      await controller.close();
    });

    test('the owner removes a member', () async {
      when(
        () => repository.removeMember(shared, otherUid),
      ).thenAnswer((_) async {});
      final controller = await sut(listValue: shared);

      expect(controller.isOwner, isTrue);
      await controller.removeMember(otherUid);
      // The owner cannot remove themself.
      await controller.removeMember(uid);

      verify(() => repository.removeMember(shared, otherUid)).called(1);
      verifyNever(() => repository.removeMember(shared, uid));
      expect(await controller.leave(), isFalse);
      await controller.close();
    });

    test('a member leaves the list', () async {
      when(
        () => authUserService.currentUser,
      ).thenReturn(const AuthUser(uid: otherUid, email: 'bob@gmail.com'));
      when(
        () => fridgeRepository.watchUsuals(otherUid),
      ).thenAnswer((_) => const Stream.empty());
      when(() => repository.leave(listId, otherUid)).thenAnswer((_) async {});
      final controller = await sut(listValue: shared);

      expect(controller.isOwner, isFalse);
      expect(await controller.leave(), isTrue);
      verify(() => repository.leave(listId, otherUid)).called(1);

      await controller.removeMember(uid);
      verifyNever(() => repository.removeMember(any(), any()));
      await controller.close();
    });
  });
}
