import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/kitchen/domain/repositories/kitchen_inventory_repository.dart';
import 'package:recipe_ai/kitchen/presentation/ingredient_controller.dart';
import 'package:recipe_ai/receipe/domain/model/ingredient.dart';

class KitchenInventoryRepository extends Mock
    implements IKitchenInventoryRepository {}

class AuthService extends Mock implements IAuthUserService {}

void main() {
  late IKitchenInventoryRepository kitchenInventoryRepository;
  late IAuthUserService authService;
  const authUser = AuthUser(
    uid: EntityId('uid'),
    email: 'uid@gmail.com',
  );
  const ingredient = Ingredient(
    id: EntityId('1'),
    name: 'Tomato',
    quantity: "10",
    date: null,
  );
  const updatedIngredient = Ingredient(
    id: EntityId('1'),
    name: 'Tomato',
    quantity: "20",
    date: null,
  );

  setUp(() {
    kitchenInventoryRepository = KitchenInventoryRepository();
    authService = AuthService();

    when(
      () => authService.currentUser,
    ).thenReturn(authUser);
  });

  IngredientController build(Ingredient ingredient) => IngredientController(
        ingredient,
        kitchenInventoryRepository,
        authService,
      );

  blocTest<IngredientController, IngredientState>(
    'should be in initial state',
    build: () => build(ingredient),
    verify: (bloc) {
      expect(bloc.state, isA<IngredientInitialState>());
    },
  );

  blocTest<IngredientController, IngredientState>(
    'should update the quantity of an ingredient',
    build: () => build(ingredient),
    setUp: () {
      when(
        () => kitchenInventoryRepository.save(
          authUser.uid,
          updatedIngredient,
        ),
      ).thenAnswer(
        (_) => Future.value(),
      );
    },
    act: (bloc) async {
      await pumpEventQueue();
      await bloc.updateIngredient("20");
    },
    verify: (bloc) {
      verify(
        () => kitchenInventoryRepository.save(
          authUser.uid,
          updatedIngredient,
        ),
      ).called(1);
    },
    expect: () => <IngredientState>[
      IngredientUpdatedState(updatedIngredient),
    ],
  );
}
