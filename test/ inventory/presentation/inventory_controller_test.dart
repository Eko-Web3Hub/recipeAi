import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/%20inventory/domain/model/category.dart';
import 'package:recipe_ai/%20inventory/domain/repositories/inventory_repository.dart';
import 'package:recipe_ai/%20inventory/presentation/inventory_controller.dart';
import 'package:recipe_ai/analytics/analytics_event.dart';
import 'package:recipe_ai/analytics/analytics_repository.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/kitchen/domain/repositories/kitchen_inventory_repository.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';

class InventoryRepositoryMock extends Mock implements IInventoryRepository {}

class AuthUserServiceMock extends Mock implements IAuthUserService {}

class KitchenInventoryRepositoryMock extends Mock
    implements IKitchenInventoryRepository {}

class AnalyticsRepositoryMock extends Mock implements IAnalyticsRepository {}

void main() {
  late IKitchenInventoryRepository kitchenInventoryRepository;
  late IAuthUserService authUserService;
  late IInventoryRepository inventoryRepository;
  late IAnalyticsRepository analyticsRepository;
  const authUser = AuthUser(
    uid: EntityId('uid'),
    email: 'email@gmail.com',
  );

  final fakeCategories = [
    Category(id: EntityId('1'), name: 'Fruits'),
    Category(id: EntityId('2'), name: 'Légumes'),
  ];

  final fakeIngredients = [
    Ingredient(
      id: const EntityId('a'),
      name: 'Banana',
      quantity: '3pcs',
      date: DateTime(2024, 1, 1),
    ),
    Ingredient(
      id: const EntityId('b'),
      name: 'Apple',
      quantity: '2pcs',
      date: DateTime(2024, 1, 2),
    ),
  ];

  final ingredientsAddedByUser = [
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

  void givenFullIngredients() {
    when(
      () => kitchenInventoryRepository.watchIngredientsAddedByUser(
        authUser.uid,
      ),
    ).thenAnswer(
      (_) => Stream.value(ingredientsAddedByUser),
    );
  }

  setUpAll(() {
    registerFallbackValue(IngredientManuallyAddedEvent());
  });

  setUp(() {
    kitchenInventoryRepository = KitchenInventoryRepositoryMock();
    authUserService = AuthUserServiceMock();
    inventoryRepository = InventoryRepositoryMock();
    analyticsRepository = AnalyticsRepositoryMock();

    when(() => authUserService.currentUser).thenReturn(authUser);
    when(() => inventoryRepository.getCategories()).thenAnswer(
      (_) => Stream.value(fakeCategories),
    );
    when(() => inventoryRepository.watchIngredients(any())).thenAnswer(
      (_) => Stream.value(fakeIngredients),
    );
    when(() => analyticsRepository.logEvent(any()))
        .thenAnswer((_) => Future.value());
  });

  InventoryController sut() => InventoryController(
        inventoryRepository,
        kitchenInventoryRepository,
        authUserService,
        analyticsRepository,
      );

  // void givenFullIngredients() {
  //   when(
  //     () => kitchenInventoryRepository.watchIngredientsAddedByUser(
  //       authUser.uid,
  //     ),
  //   ).thenAnswer(
  //     (_) => Stream.value(ingredientsAddedByUser),
  //   );
  // }

  group(
    'load categories with ingredients and ingredients added by user',
    () {
      blocTest<InventoryController, InventoryState>(
          'should load ingredients from the kitchen inventory',
          build: () => sut(),
          setUp: () {
            when(() => inventoryRepository.getCategories()).thenAnswer(
              (_) => Stream.value(fakeCategories),
            );

            when(() => inventoryRepository.watchIngredients(any())).thenAnswer(
              (_) => Stream.value(fakeIngredients),
            );

            when(
              () => kitchenInventoryRepository.watchIngredientsAddedByUser(
                authUser.uid,
              ),
            ).thenAnswer(
              (_) => Stream.value(ingredientsAddedByUser),
            );
          },
          act: (bloc) async {
            await pumpEventQueue();
          },
          expect: () => [
                // 1. Categories loaded
                InventoryState(
                  categories: fakeCategories,
                  categoryIdSelected: fakeCategories.first.id?.value,
                ),

                // 2. Ingredients added by user
                InventoryState(
                  categories: fakeCategories,
                  categoryIdSelected: fakeCategories.first.id?.value,
                  ingredientsAddedByUser: ingredientsAddedByUser,
                ),

                // 3. Ingredients of the selected category
                InventoryState(
                  categories: fakeCategories,
                  categoryIdSelected: fakeCategories.first.id?.value,
                  ingredientsAddedByUser: ingredientsAddedByUser,
                  ingredients: fakeIngredients,
                ),
              ]);
    },
  );

  group(
    'removeIngredient method',
    () {
      var ingredientTwo = Ingredient(
        name: 'Water',
        quantity: null,
        date: DateTime.now(),
        id: const EntityId('2'),
      );
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

      blocTest<InventoryController, InventoryState>(
        'should remove ingredient from inventory',
        build: () => sut(),
        setUp: () {
          // Mock des ingrédients ajoutés après suppression
          when(() => kitchenInventoryRepository.watchIngredientsAddedByUser(
                authUser.uid,
              )).thenAnswer(
            (_) => Stream.value(ingredientsWithoutIngredientTwo),
          );

          // Mock de suppression
          when(
            () => kitchenInventoryRepository.removeIngredient(
              uid: authUser.uid,
              ingredientId: ingredientTwo.id!,
            ),
          ).thenAnswer((_) async {});
        },
        act: (bloc) async {
          await pumpEventQueue();
          bloc.removeIngredient(ingredientTwo);
        },
        verify: (bloc) {
          verify(
            () => kitchenInventoryRepository.removeIngredient(
              uid: authUser.uid,
              ingredientId: ingredientTwo.id!,
            ),
          ).called(1);
        },
        expect: () => [
          // 1. Catégories chargées
          InventoryState(
            categories: fakeCategories,
            categoryIdSelected: fakeCategories.first.id?.value,
          ),

          // 2. Ingrédients ajoutés (mockés ici sans Water)
          InventoryState(
            categories: fakeCategories,
            categoryIdSelected: fakeCategories.first.id?.value,
            ingredientsAddedByUser: ingredientsWithoutIngredientTwo,
          ),

          // 3. Ingrédients de la catégorie
          InventoryState(
            categories: fakeCategories,
            categoryIdSelected: fakeCategories.first.id?.value,
            ingredients: fakeIngredients,
            ingredientsAddedByUser: ingredientsWithoutIngredientTwo,
          ),
        ],
      );
    },
  );

  group(
    'addIngredient method',
    () {
      var ingredientFour = Ingredient(
        name: 'Potatoes',
        quantity: null,
        date: DateTime.now(),
        id: const EntityId('4'),
      );
      final ingredientsWithIngredientFour = [
        ...fakeIngredients,
        ingredientFour
      ];

       List<Ingredient> filteredIngredients =
        fakeIngredients.where((ingredient) {
      return !ingredientsWithIngredientFour.any((addedIngredient) =>
          addedIngredient.name.toLowerCase() == ingredient.name.toLowerCase());
    }).toList();

      blocTest<InventoryController, InventoryState>(
        'should add ingredient to inventory',
        build: () => sut(),
        setUp: () {
          // Mock des ingrédients ajoutés après suppression
          when(() => kitchenInventoryRepository.watchIngredientsAddedByUser(
                authUser.uid,
              )).thenAnswer(
            (_) => Stream.value(ingredientsWithIngredientFour),
          );

            when(() => kitchenInventoryRepository.getIngredientsAddedByUser(
                authUser.uid,
              )).thenAnswer(
            (_) => Future.value(ingredientsWithIngredientFour),
          );

          // Mock de suppression
          when(
            () => kitchenInventoryRepository.addIngredient(
              authUser.uid,
              ingredientFour,
            ),
          ).thenAnswer((_) async {});
        },
        act: (bloc) async {
          await pumpEventQueue();
          bloc.addIngredient(ingredientFour);
        },
        verify: (bloc) {
          verify(
            () => kitchenInventoryRepository.addIngredient(
              authUser.uid,
              ingredientFour,
            ),
          ).called(1);
        },
        expect: () => [
          // 1. Catégories chargées
          InventoryState(
            categories: fakeCategories,
            categoryIdSelected: fakeCategories.first.id?.value,
          ),

          // // 2. Ingrédients ajoutés (mockés ici sans Water)
          // InventoryState(
          //   categories: fakeCategories,
          //   categoryIdSelected: fakeCategories.first.id?.value,
          //   ingredientsAddedByUser: ingredientsWithIngredientFour,
          // ),

          // 3. Ingrédients de la catégorie
          InventoryState(
            categories: fakeCategories,
            categoryIdSelected: fakeCategories.first.id?.value,
            ingredients: filteredIngredients,
            ingredientsAddedByUser: ingredientsWithIngredientFour,
          ),
        ],
      );
    },
  );

  group(
    'Search methods',
    () {
      blocTest<InventoryController, InventoryState>(
        'should emit ingredientsSuggested after searchIngredients is called',
        build: () => sut(),
        setUp: () {
          givenFullIngredients();
          when(() => inventoryRepository.searchIngredients('apple')).thenAnswer(
            (_) async => [
              Ingredient(
                id: const EntityId('z'),
                name: 'Apple',
                quantity: '2pcs',
                date: DateTime(2024, 1, 1),
              ),
            ],
          );
        },
        act: (bloc) async {
          await Future.delayed(const Duration(milliseconds: 50));
          await bloc.searchIngredients('apple');

          // attendre le debounce (200ms)
          await Future.delayed(const Duration(milliseconds: 300));
        },
        expect: () => [
          // 1. Categories loaded
          InventoryState(
            categories: fakeCategories,
            categoryIdSelected: fakeCategories.first.id?.value,
          ),

          // 2. Ingredients added by user
          InventoryState(
            categories: fakeCategories,
            categoryIdSelected: fakeCategories.first.id?.value,
            ingredientsAddedByUser: ingredientsAddedByUser,
          ),

          // 3. Ingredients of the selected category
          InventoryState(
            categories: fakeCategories,
            categoryIdSelected: fakeCategories.first.id?.value,
            ingredientsAddedByUser: ingredientsAddedByUser,
            ingredients: fakeIngredients,
          ),

          // ✅ state after search
          InventoryState(
            categories: fakeCategories,
            categoryIdSelected: fakeCategories.first.id?.value,
            ingredients: fakeIngredients,
            ingredientsSuggested: [
              Ingredient(
                id: EntityId('z'),
                name: 'Apple',
                quantity: '2pcs',
                date: DateTime(2024, 1, 1),
              ),
            ],
            ingredientsAddedByUser: ingredientsAddedByUser,
            isBusy: false,
          ),
        ],
      );
    },
  );
}
