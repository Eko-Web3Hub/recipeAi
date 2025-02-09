import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/kitchen/domain/repositories/kitchen_inventory_repository.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';
import 'package:recipe_ai/receipt_ticket_scan/presentation/receipt_ticket_scan_result_controller.dart';

class KitchenInventoryRepository extends Mock
    implements IKitchenInventoryRepository {}

class AuthUserService extends Mock implements IAuthUserService {}

void main() {
  late IKitchenInventoryRepository kitchenInventoryRepository;
  late IAuthUserService authUserService;

  const authUser = AuthUser(
    uid: EntityId('uid'),
    email: 'email@gmail.com',
  );
  final ingredients = <Ingredient>[
    Ingredient(
      name: "Tomato",
      quantity: "4",
      date: DateTime(2022, 12, 12),
      id: const EntityId("1"),
    ),
    Ingredient(
      name: "Oignon",
      quantity: "5",
      date: DateTime(2022, 12, 12),
      id: const EntityId("2"),
    ),
    Ingredient(
      name: "Salt",
      quantity: "3",
      date: DateTime(2022, 12, 12),
      id: const EntityId("3"),
    ),
  ];
  final firstUpdatedIngredients = <Ingredient>[
    Ingredient(
      name: "Tomato",
      quantity: "4",
      date: DateTime(2022, 12, 12),
      id: const EntityId("1"),
    ),
    Ingredient(
      name: "Oignon",
      quantity: "6",
      date: DateTime(2022, 12, 12),
      id: const EntityId("2"),
    ),
    Ingredient(
      name: "Salt",
      quantity: "3",
      date: DateTime(2022, 12, 12),
      id: const EntityId("3"),
    ),
  ];
  final secondUpdatedIngredients = <Ingredient>[
    Ingredient(
      name: "Tomato",
      quantity: "4",
      date: DateTime(2022, 12, 12),
      id: const EntityId("1"),
    ),
    Ingredient(
      name: "Oignon",
      quantity: "6",
      date: DateTime(2022, 12, 12),
      id: const EntityId("2"),
    ),
    Ingredient(
      name: "Salt",
      quantity: "2",
      date: DateTime(2022, 12, 12),
      id: const EntityId("3"),
    ),
  ];

  setUp(() {
    kitchenInventoryRepository = KitchenInventoryRepository();
    authUserService = AuthUserService();
  });

  ReceiptTicketScanResultController buildSut() {
    return ReceiptTicketScanResultController(
      kitchenInventoryRepository,
      authUserService,
      ingredients: ingredients,
    );
  }

  blocTest<ReceiptTicketScanResultController, ReceiptTicketScanResultState>(
    'should be in initial state',
    build: () => buildSut(),
    verify: (bloc) {
      expect(bloc.state, ReceiptTicketScanResultInitial());
    },
  );

  blocTest<ReceiptTicketScanResultController, ReceiptTicketScanResultState>(
    'should update ingredient',
    build: () => buildSut(),
    act: (bloc) {
      bloc.updateIngredient(1, 6);
      bloc.updateIngredient(2, 2);
    },
    expect: () => [
      ReceiptTicketScanUpdateIngredientSuccess(
        ingredients: firstUpdatedIngredients,
      ),
      ReceiptTicketScanUpdateIngredientSuccess(
        ingredients: secondUpdatedIngredients,
      ),
    ],
  );

  blocTest<ReceiptTicketScanResultController, ReceiptTicketScanResultState>(
    'should add ingredients to kitchen inventory',
    build: () => buildSut(),
    setUp: () {
      when(() => authUserService.currentUser).thenAnswer(
        (_) => authUser,
      );
      for (var ingredient in ingredients) {
        when(() => kitchenInventoryRepository.addIngredient(
              authUser.uid,
              ingredient,
            )).thenAnswer(
          (_) => Future.value(),
        );
      }
    },
    act: (bloc) {
      bloc.addIngredientsToKitchenInventory();
    },
    verify: (bloc) {
      for (var ingredient in ingredients) {
        verify(() => kitchenInventoryRepository.addIngredient(
              authUser.uid,
              ingredient,
            )).called(1);
      }
    },
    expect: () => [
      ReceiptTicketScanUpdateKitechenInventorySuccess(),
    ],
  );

  blocTest<ReceiptTicketScanResultController, ReceiptTicketScanResultState>(
    'should remove ingredient',
    build: () => buildSut(),
    act: (bloc) {
      bloc.removeIngredient(1);
    },
    expect: () => [
      ReceiptTicketScanUpdateIngredientSuccess(
        ingredients: [ingredients[0], ingredients[2]],
      ),
    ],
  );
}
