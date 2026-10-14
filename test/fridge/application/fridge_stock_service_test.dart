import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/fridge/application/fridge_stock_service.dart';
import 'package:recipe_ai/fridge/domain/fridge_quantity.dart';
import 'package:recipe_ai/fridge/domain/model/fridge_item.dart';
import 'package:recipe_ai/fridge/domain/model/fridge_unit.dart';
import 'package:recipe_ai/fridge/domain/repositories/fridge_repository.dart';

class FridgeRepositoryMock extends Mock implements IFridgeRepository {}

void main() {
  late IFridgeRepository fridgeRepository;
  late FridgeStockService service;

  const uid = EntityId('uid');

  final rice = FridgeItem.draft(
    name: 'Rice',
    nameFr: 'Riz',
    amount: 500,
    unit: FridgeUnit.g,
    catalogId: 'rice',
  );
  final riceInFridge = rice.copyWith(id: const EntityId('r1'));

  setUpAll(() {
    registerFallbackValue(const EntityId('fallback'));
    registerFallbackValue(FridgeItem.draft(name: 'fallback'));
  });

  setUp(() {
    fridgeRepository = FridgeRepositoryMock();
    service = FridgeStockService(fridgeRepository);

    when(() => fridgeRepository.add(uid, any())).thenAnswer(
      (invocation) async => (invocation.positionalArguments[1] as FridgeItem)
          .copyWith(id: const EntityId('new')),
    );
    when(() => fridgeRepository.update(uid, any())).thenAnswer((_) async {});
    when(() => fridgeRepository.remove(uid, any())).thenAnswer((_) async {});
  });

  void fridgeHolds(List<FridgeItem> items) => when(
    () => fridgeRepository.watchItems(uid),
  ).thenAnswer((_) => Stream.value(items));

  test('adds a new line when the ingredient is not in the fridge', () async {
    fridgeHolds([]);

    final change = await service.addOrMerge(uid, rice);

    expect(change.previous, isNull);
    expect(change.result.id, const EntityId('new'));
    verify(() => fridgeRepository.add(uid, rice)).called(1);
  });

  test('merges into the same ingredient already in the fridge', () async {
    fridgeHolds([riceInFridge]);

    final change = await service.addOrMerge(
      uid,
      FridgeItem.draft(name: 'Riz', amount: 1, unit: FridgeUnit.kg),
    );

    expect(change.previous, riceInFridge);
    expect(change.outcome, MergeOutcome.total);
    expect(change.result.amount, 1500);
    expect(change.result.unit, FridgeUnit.g);
    verify(() => fridgeRepository.update(uid, change.result)).called(1);
    verifyNever(() => fridgeRepository.add(uid, any()));
  });

  test('undo removes a new line', () async {
    fridgeHolds([]);
    final change = await service.addOrMerge(uid, rice);

    await service.undo(uid, change);

    verify(() => fridgeRepository.remove(uid, const EntityId('new'))).called(1);
  });

  test('undo puts a merged line back as it was', () async {
    fridgeHolds([riceInFridge]);
    final change = await service.addOrMerge(uid, rice);

    await service.undo(uid, change);

    verify(() => fridgeRepository.update(uid, riceInFridge)).called(1);
    verifyNever(() => fridgeRepository.remove(uid, any()));
  });

  test('nothing to undo when the fridge did not change', () async {
    fridgeHolds([riceInFridge]);
    final change = await service.addOrMerge(
      uid,
      FridgeItem.draft(name: 'Rice', catalogId: 'rice'),
    );

    expect(change.outcome, MergeOutcome.alreadyIn);
    await service.undo(uid, change);

    verifyNever(() => fridgeRepository.update(uid, any()));
    verifyNever(() => fridgeRepository.remove(uid, any()));
  });
}
