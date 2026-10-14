import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/application/user_personnal_info_service.dart';
import 'package:recipe_ai/auth/domain/model/user_personnal_info.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/shopping/domain/model/shopping_list.dart';
import 'package:recipe_ai/shopping/domain/repositories/shopping_list_repository.dart';
import 'package:recipe_ai/shopping/presentation/shopping_lists_controller.dart';

class ShoppingListRepositoryMock extends Mock
    implements IShoppingListRepository {}

class AuthUserServiceMock extends Mock implements IAuthUserService {}

class UserPersonnalInfoServiceMock extends Mock
    implements IUserPersonnalInfoService {}

void main() {
  late IShoppingListRepository repository;
  late IAuthUserService authUserService;
  late IUserPersonnalInfoService userPersonnalInfoService;
  late StreamController<List<ShoppingList>> lists;

  const uid = EntityId('uid');
  const authUser = AuthUser(uid: uid, email: 'email@gmail.com');

  final week = ShoppingList(
    id: const EntityId('week'),
    name: 'Week',
    date: DateTime(2026, 10, 14),
    ownerId: uid,
    memberIds: const [uid],
  );

  setUpAll(() {
    registerFallbackValue(const EntityId('fallback'));
    registerFallbackValue(week);
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    repository = ShoppingListRepositoryMock();
    authUserService = AuthUserServiceMock();
    userPersonnalInfoService = UserPersonnalInfoServiceMock();
    when(
      () => userPersonnalInfoService.get(),
    ).thenAnswer((_) async => const UserPersonnalInfo(uid: uid, name: 'Ana'));
    lists = StreamController<List<ShoppingList>>();

    when(() => authUserService.currentUser).thenReturn(authUser);
    when(() => repository.watchLists(uid)).thenAnswer((_) => lists.stream);
  });

  tearDown(() => lists.close());

  Future<ShoppingListsController> sut() async {
    final controller = ShoppingListsController(
      repository,
      authUserService,
      userPersonnalInfoService,
    );
    await pumpEventQueue();
    return controller;
  }

  test('emits the lists of the user', () async {
    final controller = await sut();
    expect(controller.state.status, ShoppingListsStatus.loading);

    lists.add([week]);
    await pumpEventQueue();

    expect(controller.state.status, ShoppingListsStatus.loaded);
    expect(controller.state.lists, [week]);
    await controller.close();
  });

  test('goes to error when the lists cannot be read', () async {
    final controller = await sut();
    lists.addError(Exception('denied'));
    await pumpEventQueue();

    expect(controller.state.status, ShoppingListsStatus.error);
    await controller.close();
  });

  test('creates a list with a trimmed name, owned by the user', () async {
    when(
      () => repository.createList(uid, any(), any(), any()),
    ).thenAnswer((_) async => week);
    final controller = await sut();

    final created = await controller.create('  Week ', DateTime(2026, 10, 14));

    expect(created, week);
    verify(
      () => repository.createList(uid, 'Ana', 'Week', DateTime(2026, 10, 14)),
    ).called(1);
    await controller.close();
  });

  test('a failed creation returns null and reports an error', () async {
    when(
      () => repository.createList(uid, any(), any(), any()),
    ).thenThrow(Exception('offline'));
    final controller = await sut();

    expect(await controller.create('Week', DateTime(2026)), isNull);
    expect(controller.state.errorCount, 1);
    await controller.close();
  });

  test('updates, deletes and leaves a list', () async {
    when(() => repository.updateList(any())).thenAnswer((_) async {});
    when(() => repository.deleteList(any())).thenAnswer((_) async {});
    when(() => repository.leave(any(), any())).thenAnswer((_) async {});
    final controller = await sut();

    await controller.update(week, 'Weekend', DateTime(2026, 10, 18));
    verify(
      () => repository.updateList(
        week.copyWith(name: 'Weekend', date: DateTime(2026, 10, 18)),
      ),
    ).called(1);

    await controller.delete(week);
    verify(() => repository.deleteList(week)).called(1);

    await controller.leave(week);
    verify(() => repository.leave(week.id, uid)).called(1);
    await controller.close();
  });

  test('only the owner owns the list', () async {
    final controller = await sut();

    expect(controller.isOwner(week), isTrue);
    expect(
      controller.isOwner(
        ShoppingList(
          id: const EntityId('shared'),
          name: 'Shared',
          date: DateTime(2026),
          ownerId: const EntityId('other'),
          memberIds: const [EntityId('other'), uid],
        ),
      ),
      isFalse,
    );
    await controller.close();
  });
}
