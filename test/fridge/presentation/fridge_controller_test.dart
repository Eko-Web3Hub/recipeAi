import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/analytics/analytics_event.dart';
import 'package:recipe_ai/analytics/analytics_repository.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/fridge/domain/fridge_quantity.dart';
import 'package:recipe_ai/fridge/domain/model/catalog_ingredient.dart';
import 'package:recipe_ai/fridge/domain/model/fridge_item.dart';
import 'package:recipe_ai/fridge/domain/model/fridge_unit.dart';
import 'package:recipe_ai/fridge/domain/repositories/fridge_repository.dart';
import 'package:recipe_ai/fridge/presentation/fridge_controller.dart';

class FridgeRepositoryMock extends Mock implements IFridgeRepository {}

class IngredientCatalogRepositoryMock extends Mock
    implements IIngredientCatalogRepository {}

class AuthUserServiceMock extends Mock implements IAuthUserService {}

class AnalyticsRepositoryMock extends Mock implements IAnalyticsRepository {}

void main() {
  late IFridgeRepository fridgeRepository;
  late IIngredientCatalogRepository catalogRepository;
  late IAuthUserService authUserService;
  late IAnalyticsRepository analyticsRepository;
  late StreamController<List<FridgeItem>> items;
  late StreamController<List<FridgeItem>> usuals;

  const uid = EntityId('uid');
  const authUser = AuthUser(uid: uid, email: 'email@gmail.com');

  const catalog = [
    CatalogIngredient(
      id: 'tomato',
      name: 'Tomatoes',
      nameFr: 'Tomates',
      defaultUnit: FridgeUnit.kg,
      defaultAmount: 1,
    ),
    CatalogIngredient(
      id: 'okra',
      name: 'Okra',
      nameFr: 'Gombo',
      defaultUnit: FridgeUnit.tas,
      defaultAmount: 1,
      units: [FridgeUnit.tas, FridgeUnit.bol, FridgeUnit.kg],
      aliases: ['gombos'],
    ),
    CatalogIngredient(id: 'milk', name: 'Milk', nameFr: 'Lait'),
    CatalogIngredient(id: 'coco', name: 'Coconut milk', nameFr: 'Lait de coco'),
  ];

  final tomatoes = FridgeItem.draft(
    name: 'Tomatoes',
    nameFr: 'Tomates',
    amount: 1,
    unit: FridgeUnit.kg,
    catalogId: 'tomato',
  ).copyWith(id: const EntityId('t1'));

  setUpAll(() {
    registerFallbackValue(const EntityId('fallback'));
    registerFallbackValue(FridgeItem.draft(name: 'fallback'));
    registerFallbackValue(IngredientManuallyAddedEvent());
  });

  setUp(() {
    fridgeRepository = FridgeRepositoryMock();
    catalogRepository = IngredientCatalogRepositoryMock();
    authUserService = AuthUserServiceMock();
    analyticsRepository = AnalyticsRepositoryMock();
    items = StreamController<List<FridgeItem>>();
    usuals = StreamController<List<FridgeItem>>();

    when(() => authUserService.currentUser).thenReturn(authUser);
    when(
      () => fridgeRepository.watchItems(uid),
    ).thenAnswer((_) => items.stream);
    when(
      () => fridgeRepository.watchUsuals(uid),
    ).thenAnswer((_) => usuals.stream);
    when(
      () => catalogRepository.loadCatalog(),
    ).thenAnswer((_) async => catalog);
    when(() => fridgeRepository.add(uid, any())).thenAnswer(
      (invocation) async => (invocation.positionalArguments[1] as FridgeItem)
          .copyWith(id: const EntityId('new')),
    );
    when(() => fridgeRepository.update(uid, any())).thenAnswer((_) async {});
    when(() => fridgeRepository.remove(uid, any())).thenAnswer((_) async {});
    when(() => fridgeRepository.restore(uid, any())).thenAnswer((_) async {});
    when(() => analyticsRepository.logEvent(any())).thenAnswer((_) async {});
  });

  tearDown(() async {
    await items.close();
    await usuals.close();
  });

  Future<FridgeController> sut({List<FridgeItem> initial = const []}) async {
    final controller = FridgeController(
      fridgeRepository,
      catalogRepository,
      authUserService,
      analyticsRepository,
    );
    items.add(initial);
    await pumpEventQueue();
    return controller;
  }

  group('loading', () {
    test('emits the fridge items and the default usuals', () async {
      final controller = await sut(initial: [tomatoes]);

      expect(controller.state.status, FridgeStatus.loaded);
      expect(controller.state.items, [tomatoes]);
      expect(
        controller.state.usuals.map((usual) => usual.name),
        defaultFridgeUsuals.take(5).map((usual) => usual.name),
      );
      await controller.close();
    });

    test('offers the usual history, without what is already in', () async {
      final controller = await sut(initial: [tomatoes]);
      usuals.add([
        tomatoes.copyWith(amount: () => 2),
        FridgeItem.draft(name: 'Rice', nameFr: 'Riz'),
      ]);
      await pumpEventQueue();

      expect(controller.state.usuals.map((usual) => usual.name), ['Rice']);
      await controller.close();
    });

    test('goes to error when the fridge cannot be read', () async {
      final controller = FridgeController(
        fridgeRepository,
        catalogRepository,
        authUserService,
        analyticsRepository,
      );
      items.addError(Exception('denied'));
      await pumpEventQueue();

      expect(controller.state.status, FridgeStatus.error);
      await controller.close();
    });
  });

  group('suggestions', () {
    test('lists prefix matches first, then word matches', () async {
      final controller = await sut();
      controller.onQueryChanged('lai');

      // No exact match: a free-text entry closes the list.
      expect(controller.state.suggestions.map((s) => s.draft.catalogId), [
        'milk',
        'coco',
        null,
      ]);
      expect(controller.state.suggestions.last.isCustom, isTrue);
      await controller.close();
    });

    test('finds aliases and flags ingredients already in', () async {
      final controller = await sut(initial: [tomatoes]);

      controller.onQueryChanged('gombos');
      expect(controller.state.suggestions.first.draft.catalogId, 'okra');

      controller.onQueryChanged('tomate');
      expect(controller.state.suggestions.first.isInFridge, isTrue);
      await controller.close();
    });

    test('offers a free-text entry when nothing matches exactly', () async {
      final controller = await sut();
      controller.onQueryChanged('attiéké');

      expect(controller.state.suggestions.single.isCustom, isTrue);
      expect(controller.state.suggestions.single.draft.name, 'Attiéké');
      await controller.close();
    });

    test('units of the sheet come from the catalog', () async {
      final controller = await sut();
      final okra = resolveDraft(parseExpress('gombo'), catalog[1]);

      expect(controller.unitsFor(okra), [
        FridgeUnit.tas,
        FridgeUnit.bol,
        FridgeUnit.kg,
      ]);
      await controller.close();
    });
  });

  group('submitQuery', () {
    test('adds a typed quantity directly', () async {
      final controller = await sut();
      controller.onQueryChanged('500 g tomates');

      final draft = await controller.submitQuery();

      expect(draft, isNull);
      final added =
          verify(() => fridgeRepository.add(uid, captureAny())).captured.single
              as FridgeItem;
      expect(added.catalogId, 'tomato');
      expect(added.amount, 500);
      expect(added.unit, FridgeUnit.g);
      expect(controller.state.query, isEmpty);
      await controller.close();
    });

    test('returns the draft to open in the sheet otherwise', () async {
      final controller = await sut();
      controller.onQueryChanged('gombo');

      final draft = await controller.submitQuery();

      expect(draft?.catalogId, 'okra');
      expect(draft?.unit, FridgeUnit.tas);
      verifyNever(() => fridgeRepository.add(uid, any()));
      await controller.close();
    });
  });

  group('add', () {
    test('adds a new ingredient and highlights it', () async {
      final controller = await sut();

      await controller.add(FridgeItem.draft(name: 'Rice', amount: 1));

      verify(() => fridgeRepository.add(uid, any())).called(1);
      verify(() => analyticsRepository.logEvent(any())).called(1);
      expect(controller.state.highlightedId, 'new');
      await controller.close();
    });

    test('merges into the same ingredient already in', () async {
      final controller = await sut(initial: [tomatoes]);

      await controller.add(
        FridgeItem.draft(
          name: 'Tomatoes',
          amount: 500,
          unit: FridgeUnit.g,
          catalogId: 'tomato',
        ),
      );

      final updated =
          verify(
                () => fridgeRepository.update(uid, captureAny()),
              ).captured.single
              as FridgeItem;
      expect(updated.id, tomatoes.id);
      expect(updated.amount, 1.5);
      verifyNever(() => fridgeRepository.add(uid, any()));
      final feedback = controller.state.feedback as FridgeItemMergedFeedback;
      expect(feedback.outcome, MergeOutcome.total);
      await controller.close();
    });

    test('reports an error when the write fails', () async {
      when(() => fridgeRepository.add(uid, any())).thenThrow(Exception());
      final controller = await sut();

      await controller.add(FridgeItem.draft(name: 'Rice'));

      expect(controller.state.feedback, isA<FridgeErrorFeedback>());
      await controller.close();
    });
  });

  group('edit and remove', () {
    test('save updates the item', () async {
      final controller = await sut(initial: [tomatoes]);
      final edited = tomatoes.copyWith(amount: () => 2);

      await controller.save(edited);

      verify(() => fridgeRepository.update(uid, edited)).called(1);
      await controller.close();
    });

    test('remove then undo restores the same item', () async {
      final controller = await sut(initial: [tomatoes]);

      await controller.remove(tomatoes);
      verify(() => fridgeRepository.remove(uid, tomatoes.id!)).called(1);
      final feedback = controller.state.feedback as FridgeItemRemovedFeedback;
      expect(feedback.item, tomatoes);

      await controller.undoRemove(feedback.item);
      verify(() => fridgeRepository.restore(uid, tomatoes)).called(1);
      await controller.close();
    });
  });

  test('usual chips are completed with the catalog', () async {
    final controller = await sut();
    final okra = defaultFridgeUsuals.firstWhere((u) => u.name == 'Okra');

    final draft = controller.draftForUsual(okra);

    expect(draft.catalogId, 'okra');
    expect(draft.unit, FridgeUnit.tas);
    await controller.close();
  });
}
