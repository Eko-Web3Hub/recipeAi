import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/kitchen/domain/repositories/kitchen_inventory_repository.dart';
import 'package:recipe_ai/kitchen/presentation/kitchen_inventory_controller.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';

class KitchenInventoryRepositoryMock extends Mock
    implements IKitchenInventoryRepository {}

class AuthUserService extends Mock implements IAuthUserService {}

void main() {
  late IKitchenInventoryRepository kitchenInventoryRepository;
  late IAuthUserService authUserService;
  const authUser = AuthUser(
    uid: EntityId('uid'),
    email: 'email@gmail.com',
  );
  final ingredients = [
    Ingredient(
      id: const EntityId('1'),
      name: 'Tomatoes',
      quantity: '3pcs',
      date: DateTime.now(),
    ),
    Ingredient(
      name: 'Water',
      quantity: null,
      date: DateTime.now(),
      id: const EntityId('2'),
    ),
    Ingredient(
      name: 'Steak',
      quantity: null,
      date: DateTime.now(),
      id: const EntityId('3'),
    ),
  ];

  setUp(() {
    kitchenInventoryRepository = KitchenInventoryRepositoryMock();
    authUserService = AuthUserService();

    when(() => authUserService.currentUser).thenReturn(authUser);
  });

  KitchenInventoryController sut() => KitchenInventoryController(
        kitchenInventoryRepository,
        authUserService,
      );

  void givenFullIngredients() {
    when(
      () => kitchenInventoryRepository.watchIngredientsAddedByUser(
        authUser.uid,
      ),
    ).thenAnswer(
      (_) => Stream.value(ingredients),
    );
  }

  group(
    'searchForIngredients method',
    () {
      blocTest<KitchenInventoryController, KitchenState>(
        'should search for ingredients in the kitchen inventory',
        build: () => sut(),
        setUp: () {
          givenFullIngredients();
          when(
            () => kitchenInventoryRepository.searchForIngredients(
              authUser.uid,
              'Tomatoes',
            ),
          ).thenAnswer(
            (_) => Future.value(
              [
                Ingredient(
                  id: const EntityId('1'),
                  name: 'Tomatoes',
                  quantity: '3pcs',
                  date: DateTime.now(),
                ),
              ],
            ),
          );
        },
        act: (bloc) async {
          await pumpEventQueue();
          bloc.searchForIngredients('Tomatoes');
        },
        verify: (bloc) {
          verify(
            () => kitchenInventoryRepository.searchForIngredients(
              authUser.uid,
              'Tomatoes',
            ),
          ).called(1);
        },
        expect: () => [
          KitchenStateLoaded(
            ingredients: ingredients,
            ingredientsFiltered: ingredients,
          ),
          KitchenStateLoaded(
            ingredients: ingredients,
            ingredientsFiltered: [
              Ingredient(
                id: const EntityId('1'),
                name: 'Tomatoes',
                quantity: '3pcs',
                date: DateTime.now(),
              ),
            ],
          ),
        ],
      );

      blocTest<KitchenInventoryController, KitchenState>(
        'should emit error state when search for ingredients fails',
        build: () => sut(),
        setUp: () {
          givenFullIngredients();
          when(
            () => kitchenInventoryRepository.searchForIngredients(
              authUser.uid,
              'Tomatoes',
            ),
          ).thenThrow(
            Exception('An error occurred'),
          );
        },
        act: (bloc) async {
          await pumpEventQueue();
          bloc.searchForIngredients('Tomatoes');
        },
        expect: () => [
          KitchenStateLoaded(
            ingredients: ingredients,
            ingredientsFiltered: ingredients,
          ),
          isA<KitchenStateError>(),
        ],
      );
    },
  );

  group(
    'loadIngredients method',
    () {
      blocTest<KitchenInventoryController, KitchenState>(
        'should load ingredients from the kitchen inventory',
        build: () => sut(),
        setUp: () {
          when(
            () => kitchenInventoryRepository.watchIngredientsAddedByUser(
              authUser.uid,
            ),
          ).thenAnswer(
            (_) => Stream.value(ingredients),
          );
        },
        act: (bloc) async {
          await pumpEventQueue();
        },
        expect: () => [
          KitchenStateLoaded(
            ingredients: ingredients,
            ingredientsFiltered: ingredients,
          ),
        ],
      );
    },
  );

  group(
    'removeIngredient method',
    () {
      const ingredientTwoId = EntityId('2');
      final ingredientsWithoutIngredientTwo = [
        Ingredient(
          id: const EntityId('1'),
          name: 'Tomatoes',
          quantity: '3pcs',
          date: DateTime.now(),
        ),
        Ingredient(
          name: 'Steak',
          quantity: null,
          date: DateTime.now(),
          id: const EntityId('3'),
        ),
      ];

      blocTest<KitchenInventoryController, KitchenState>(
        'should remove ingredient from the kitchen inventory',
        build: () => sut(),
        setUp: () {
          givenFullIngredients();
          when(
            () => kitchenInventoryRepository.removeIngredient(
              uid: authUser.uid,
              ingredientId: ingredientTwoId,
            ),
          ).thenAnswer(
            (_) => Future.value(),
          );
        },
        act: (bloc) async {
          await pumpEventQueue();
          bloc.removeIngredient(ingredientTwoId);
        },
        verify: (bloc) {
          verify(
            () => kitchenInventoryRepository.removeIngredient(
              uid: authUser.uid,
              ingredientId: ingredientTwoId,
            ),
          ).called(1);
        },
        expect: () => [
          KitchenStateLoaded(
            ingredients: ingredients,
            ingredientsFiltered: ingredients,
          ),
          KitchenStateLoaded(
            ingredients: ingredientsWithoutIngredientTwo,
            ingredientsFiltered: ingredientsWithoutIngredientTwo,
          ),
        ],
      );
    },
  );
}
