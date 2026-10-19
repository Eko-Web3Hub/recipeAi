import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/fridge/domain/model/fridge_item.dart';
import 'package:recipe_ai/fridge/domain/model/fridge_unit.dart';
import 'package:recipe_ai/fridge/presentation/generate_recipe_from_fridge_selection_controller.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository_v2.dart';

class AuthUserServiceMock extends Mock implements IAuthUserService {}

class UserReceipeRepositoryV2Mock extends Mock
    implements IUserReceipeRepositoryV2 {}

void main() {
  late IAuthUserService authUserService;
  late IUserReceipeRepositoryV2 userReceipeRepository;
  late List<UserRecipeV2> generated;

  const authUser = AuthUser(uid: EntityId('uid'), email: 'email@gmail.com');
  const token = 'id-token';

  final tomatoes = FridgeItem.draft(
    name: 'Tomatoes',
    amount: 1,
    unit: FridgeUnit.kg,
  );

  const receipe = Receipe(
    name: 'name',
    ingredients: [],
    steps: [],
    averageTime: '',
    totalCalories: '',
  );
  final recipe = UserRecipeV2(
    id: const EntityId('recipeId'),
    receipeFr: receipe,
    receipeEn: receipe,
    createdDate: DateTime(2024, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(const EntityId('fallback'));
  });

  setUp(() {
    authUserService = AuthUserServiceMock();
    userReceipeRepository = UserReceipeRepositoryV2Mock();
    generated = [];

    when(() => authUserService.currentUser).thenReturn(authUser);
    when(
      () => authUserService.getIdToken,
    ).thenAnswer((_) => Future.value(token));
    when(
      () => userReceipeRepository.save(any(), any()),
    ).thenAnswer((invocation) async => invocation.positionalArguments[1]);
  });

  GenerateRecipeFromFridgeSelectionController buildSut() =>
      GenerateRecipeFromFridgeSelectionController(
        userReceipeRepository,
        authUserService,
        (recipes) => generated = recipes,
      );

  blocTest<
    GenerateRecipeFromFridgeSelectionController,
    GenerateRecipeFromFridgeSelectionState
  >(
    'generate saves and reports the recipes through onGenerated, resting back at idle',
    setUp: () {
      when(
        () => userReceipeRepository.generateRecipesWithIngredientList(
          authUser.uid,
          token,
          [tomatoes],
        ),
      ).thenAnswer((_) async => [recipe]);
    },
    build: buildSut,
    act: (controller) => controller.generate([tomatoes]),
    expect: () => [
      isA<GenerateRecipeFromFridgeSelectionLoading>(),
      isA<GenerateRecipeFromFridgeSelectionIdle>(),
    ],
    verify: (_) {
      expect(generated, [recipe]);
      verify(() => userReceipeRepository.save(authUser.uid, [recipe])).called(1);
    },
  );

  blocTest<
    GenerateRecipeFromFridgeSelectionController,
    GenerateRecipeFromFridgeSelectionState
  >(
    'a not-enough-ingredients refusal is reported with its minimum and provided count',
    setUp: () {
      when(
        () => userReceipeRepository.generateRecipesWithIngredientList(
          any(),
          any(),
          any(),
        ),
      ).thenThrow(const NotEnoughIngredientsException(minimum: 3, provided: 1));
    },
    build: buildSut,
    act: (controller) => controller.generate([tomatoes]),
    expect: () => [
      isA<GenerateRecipeFromFridgeSelectionLoading>(),
      isA<GenerateRecipeFromFridgeSelectionNotEnoughIngredients>()
          .having((s) => s.minimum, 'minimum', 3)
          .having((s) => s.provided, 'provided', 1),
    ],
    verify: (_) => expect(generated, isEmpty),
  );

  blocTest<
    GenerateRecipeFromFridgeSelectionController,
    GenerateRecipeFromFridgeSelectionState
  >(
    'any other failure falls back to a generic failure state',
    setUp: () {
      when(
        () => userReceipeRepository.generateRecipesWithIngredientList(
          any(),
          any(),
          any(),
        ),
      ).thenThrow(Exception('network down'));
    },
    build: buildSut,
    act: (controller) => controller.generate([tomatoes]),
    expect: () => [
      isA<GenerateRecipeFromFridgeSelectionLoading>(),
      isA<GenerateRecipeFromFridgeSelectionFailure>(),
    ],
  );

  blocTest<
    GenerateRecipeFromFridgeSelectionController,
    GenerateRecipeFromFridgeSelectionState
  >(
    'a null id token is a generic failure, not a crash',
    setUp: () {
      when(() => authUserService.getIdToken).thenAnswer((_) => Future.value());
    },
    build: buildSut,
    act: (controller) => controller.generate([tomatoes]),
    expect: () => [
      isA<GenerateRecipeFromFridgeSelectionLoading>(),
      isA<GenerateRecipeFromFridgeSelectionFailure>(),
    ],
  );
}
