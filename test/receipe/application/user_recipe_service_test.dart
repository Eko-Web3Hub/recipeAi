import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/application/user_recipe_service.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository_v2.dart';

class AuthUserServiceMock extends Mock implements IAuthUserService {}

class UserReceipeRepositoryV2Mock extends Mock
    implements IUserReceipeRepositoryV2 {}

void main() {
  late IAuthUserService authUserService;
  late IUserReceipeRepositoryV2 userReceipeRepositoryV2;

  const authUser = AuthUser(uid: EntityId('uid'), email: 'email');

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

  setUp(() {
    authUserService = AuthUserServiceMock();
    userReceipeRepositoryV2 = UserReceipeRepositoryV2Mock();

    when(() => authUserService.currentUser).thenReturn(authUser);
  });

  UserRecipeService buildSut() =>
      UserRecipeService(userReceipeRepositoryV2, authUserService);

  test(
    'addToFavorite delegates to the repository with the current uid',
    () async {
      when(
        () => userReceipeRepositoryV2.addToFavorite(
          uid: authUser.uid,
          recipeId: recipe.id!,
          recipe: recipe,
        ),
      ).thenAnswer((_) => Future.value());

      await buildSut().addToFavorite(recipe);

      verify(
        () => userReceipeRepositoryV2.addToFavorite(
          uid: authUser.uid,
          recipeId: recipe.id!,
          recipe: recipe,
        ),
      ).called(1);
    },
  );

  test(
    'removeFromFavorite delegates to the repository with the current uid',
    () async {
      when(
        () => userReceipeRepositoryV2.removeFromFavorite(
          uid: authUser.uid,
          recipeId: recipe.id!,
        ),
      ).thenAnswer((_) => Future.value());

      await buildSut().removeFromFavorite(recipe);

      verify(
        () => userReceipeRepositoryV2.removeFromFavorite(
          uid: authUser.uid,
          recipeId: recipe.id!,
        ),
      ).called(1);
    },
  );

  test('watchAllSavedReceipes streams the repository favorite recipes', () {
    when(
      () => userReceipeRepositoryV2.retrieveFavoriteRecipes(authUser.uid),
    ).thenAnswer((_) => Stream.value([recipe]));

    expect(buildSut().watchAllSavedReceipes(), emits(equals([recipe])));
  });

  test('isReceiptSaved delegates to the repository with the current uid', () {
    when(
      () => userReceipeRepositoryV2.isReceiptSaved(authUser.uid, recipe.id!),
    ).thenAnswer((_) => Stream.value(true));

    expect(buildSut().isReceiptSaved(recipe.id!), emits(true));
  });
}
