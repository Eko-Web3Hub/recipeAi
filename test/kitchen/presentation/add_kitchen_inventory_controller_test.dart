import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/kitchen/domain/repositories/kitchen_inventory_repository.dart';
import 'package:recipe_ai/kitchen/presentation/add_kitchen_inventory_controller.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';

class KitchenInventoryRepositoryMock extends Mock
    implements IKitchenInventoryRepository {}

class AuthUserServiceMock extends Mock implements IAuthUserService {}

void main() {
  late IKitchenInventoryRepository kitchenInventoryRepository;
  late IAuthUserService authUserService;
  final ingredient = Ingredient(
    name: 'name',
    quantity: 'quantity',
    date: DateTime(2024),
    id: const EntityId('id'),
  );
  const AuthUser authUser = AuthUser(
    uid: EntityId("uid"),
    email: "test@gmail.com",
  );

  setUp(() {
    kitchenInventoryRepository = KitchenInventoryRepositoryMock();
    authUserService = AuthUserServiceMock();
  });

  AddKitchenInventoryController buildSut() {
    return AddKitchenInventoryController(
      kitchenInventoryRepository,
      authUserService,
    );
  }

  blocTest<AddKitchenInventoryController, AddKitchenState?>(
    'should initialy be in loading state',
    build: () => buildSut(),
    verify: (bloc) => {
      expect(bloc.state, isNull),
    },
  );

  blocTest<AddKitchenInventoryController, AddKitchenState?>(
    'Should add ingredients',
    build: () => buildSut(),
    setUp: () {
      when(
        () {
          return authUserService.currentUser;
        },
      ).thenReturn(authUser);
      when(() => kitchenInventoryRepository.addIngredient(
            authUser.uid,
            ingredient,
          )).thenAnswer(
        (_) => Future.value(),
      );
    },
    act: (bloc) => bloc.addKitchenInventory(
        name: ingredient.name,
        quantity: ingredient.quantity!,
        timestamp: ingredient.date!),
    verify: (bloc) => {
      verify(() => kitchenInventoryRepository.addIngredient(
            authUser.uid,
            ingredient,
          )).called(1),
      expect(bloc.state, equals(AddKitchenSuccess())),
    },
  );

  blocTest<AddKitchenInventoryController, AddKitchenState?>(
    'Should return error when adding ingredients fails',
    build: () => buildSut(),
    setUp: () {
      when(
        () {
          return authUserService.currentUser;
        },
      ).thenReturn(authUser);
      when(() => kitchenInventoryRepository.addIngredient(
            authUser.uid,
            ingredient,
          )).thenThrow(Exception('Error'));
    },
    act: (bloc) => bloc.addKitchenInventory(
        name: ingredient.name,
        quantity: ingredient.quantity!,
        timestamp: ingredient.date!),
    verify: (bloc) => {
      verify(() => kitchenInventoryRepository.addIngredient(
            authUser.uid,
            ingredient,
          )).called(1),
      expect(bloc.state, equals(AddKitchenFailed(message: 'Exception: Error'))),
    },
  );
}
