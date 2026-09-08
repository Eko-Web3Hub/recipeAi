import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/application/retrieve_receipe_from_api_one_time_per_day_usecase.dart';
import 'package:recipe_ai/receipe/application/user_recipe_service.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository_v2.dart';
import 'package:recipe_ai/utils/local_storage_repo.dart';

class AuthUserServiceMock extends Mock implements IAuthUserService {}

class UserReceipeRepositoryV2Mock extends Mock
    implements IUserReceipeRepositoryV2 {}

class UserRecipeServiceMock extends Mock implements IUserRecipeService {}

class LocalStorageRepositoryMock extends Mock
    implements ILocalStorageRepository {}

void main() {
  late IAuthUserService authUserService;
  late IUserReceipeRepositoryV2 userReceipeRepositoryV2;
  late IUserRecipeService userRecipeService;
  late ILocalStorageRepository localStorageRepository;

  const authUser = AuthUser(uid: EntityId('uid'), email: 'email');
  const token = 'token';

  const receipe = Receipe(
    name: 'name',
    ingredients: [],
    steps: [],
    averageTime: '',
    totalCalories: '',
  );

  final apiRecipes = [
    UserRecipeV2(
      id: const EntityId('apiId'),
      receipeFr: receipe,
      receipeEn: receipe,
      createdDate: DateTime(2024, 1, 1),
    ),
  ];

  final localRecipes = [
    UserRecipeV2(
      id: const EntityId('localId'),
      receipeFr: receipe,
      receipeEn: receipe,
      createdDate: DateTime(2024, 1, 1),
    ),
  ];

  setUp(() {
    authUserService = AuthUserServiceMock();
    userReceipeRepositoryV2 = UserReceipeRepositoryV2Mock();
    userRecipeService = UserRecipeServiceMock();
    localStorageRepository = LocalStorageRepositoryMock();

    when(() => authUserService.currentUser).thenReturn(authUser);
    when(
      () => authUserService.getIdToken,
    ).thenAnswer((_) => Future.value(token));
  });

  RetrieveReceipeFromApiOneTimePerDayUsecase buildSut() =>
      RetrieveReceipeFromApiOneTimePerDayUsecase(
        authUserService,
        userReceipeRepositoryV2,
        userRecipeService,
        localStorageRepository,
      );

  void stubRefresh(DateTime now) {
    when(
      () => userReceipeRepositoryV2.suggestedRecipes(authUser.uid, token),
    ).thenAnswer((_) => Future.value(apiRecipes));
    when(
      () => localStorageRepository.setSuggestedRecipes(apiRecipes),
    ).thenAnswer((_) => Future.value());
    when(
      () => userRecipeService.saveUserReceipeMetadata(authUser.uid, now),
    ).thenAnswer((_) => Future.value());
  }

  test(
    'should retrieve and cache new recipes when there is no metadata yet',
    () async {
      final now = DateTime(2024, 1, 2);

      when(
        () => userRecipeService.getUserRecipeMetadata(authUser.uid),
      ).thenAnswer((_) => Future.value(null));
      stubRefresh(now);

      final recipes = await buildSut().retrieve(now);

      verify(
        () => userReceipeRepositoryV2.suggestedRecipes(authUser.uid, token),
      ).called(1);
      verify(
        () => localStorageRepository.setSuggestedRecipes(apiRecipes),
      ).called(1);
      verify(
        () => userRecipeService.saveUserReceipeMetadata(authUser.uid, now),
      ).called(1);
      expect(recipes, equals(apiRecipes));
    },
  );

  test(
    'should retrieve and cache new recipes when the metadata has no last updated date',
    () async {
      final now = DateTime(2024, 1, 2);

      when(
        () => userRecipeService.getUserRecipeMetadata(authUser.uid),
      ).thenAnswer((_) => Future.value(const UserRecipeMetadata.initial()));
      stubRefresh(now);

      final recipes = await buildSut().retrieve(now);

      verify(
        () => userReceipeRepositoryV2.suggestedRecipes(authUser.uid, token),
      ).called(1);
      expect(recipes, equals(apiRecipes));
    },
  );

  test('should retrieve new recipes when the last update was on a previous '
      'calendar day, even if less than 24h ago', () async {
    final lastUpdatedDate = DateTime(2024, 1, 1, 23, 45);
    final now = DateTime(2024, 1, 2, 0, 30);

    when(
      () => userRecipeService.getUserRecipeMetadata(authUser.uid),
    ).thenAnswer(
      (_) => Future.value(
        UserRecipeMetadata(lastRecipesHomeUpdatedDate: lastUpdatedDate),
      ),
    );
    stubRefresh(now);

    final recipes = await buildSut().retrieve(now);

    verify(
      () => userReceipeRepositoryV2.suggestedRecipes(authUser.uid, token),
    ).called(1);
    expect(recipes, equals(apiRecipes));
  });

  test('should return recipes cached in local storage when the last update was '
      'earlier the same calendar day, even close to 24h ago', () async {
    final lastUpdatedDate = DateTime(2024, 1, 1, 0, 5);
    final now = DateTime(2024, 1, 1, 23, 55);

    when(
      () => userRecipeService.getUserRecipeMetadata(authUser.uid),
    ).thenAnswer(
      (_) => Future.value(
        UserRecipeMetadata(lastRecipesHomeUpdatedDate: lastUpdatedDate),
      ),
    );
    when(
      () => localStorageRepository.getSuggestedRecipes(),
    ).thenAnswer((_) => Future.value(localRecipes));

    final recipes = await buildSut().retrieve(now);

    verifyNever(
      () => userReceipeRepositoryV2.suggestedRecipes(authUser.uid, token),
    );
    expect(recipes, equals(localRecipes));
  });

  test(
    'should return an empty list when there is nothing cached in local storage',
    () async {
      final now = DateTime(2024, 1, 1, 12);

      when(
        () => userRecipeService.getUserRecipeMetadata(authUser.uid),
      ).thenAnswer(
        (_) => Future.value(
          UserRecipeMetadata(lastRecipesHomeUpdatedDate: DateTime(2024, 1, 1)),
        ),
      );
      when(
        () => localStorageRepository.getSuggestedRecipes(),
      ).thenAnswer((_) => Future.value(null));

      final recipes = await buildSut().retrieve(now);

      expect(recipes, isEmpty);
    },
  );

  test(
    'should throw a UserNotAuthenticatedException when the user is not authenticated',
    () async {
      when(() => authUserService.currentUser).thenReturn(null);

      expect(
        () => buildSut().retrieve(DateTime(2024, 1, 1)),
        throwsA(isA<UserNotAuthenticatedException>()),
      );
      verifyNever(() => userRecipeService.getUserRecipeMetadata(authUser.uid));
    },
  );

  test(
    'should throw a UserNotAuthenticatedException when there is no auth token available',
    () async {
      final now = DateTime(2024, 1, 2);

      when(
        () => userRecipeService.getUserRecipeMetadata(authUser.uid),
      ).thenAnswer((_) => Future.value(null));
      when(
        () => authUserService.getIdToken,
      ).thenAnswer((_) => Future.value(null));

      expect(
        () => buildSut().retrieve(now),
        throwsA(isA<UserNotAuthenticatedException>()),
      );
      verifyNever(
        () => userReceipeRepositoryV2.suggestedRecipes(authUser.uid, token),
      );
      verifyNever(
        () => userRecipeService.saveUserReceipeMetadata(authUser.uid, now),
      );
    },
  );

  test(
    'should throw a RetrieveReceipeException when an error occurs',
    () async {
      when(
        () => userRecipeService.getUserRecipeMetadata(authUser.uid),
      ).thenThrow(Exception());

      expect(
        () => buildSut().retrieve(DateTime(2024, 1, 1)),
        throwsA(isA<RetrieveReceipeException>()),
      );
    },
  );
}
