import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/application/retrieve_receipe_from_api_one_time_per_day_usecase.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository.dart';

class UserReceipeRepositoryMock extends Mock
    implements IUserReceipeRepository {}

class AuthUserServiceMock extends Mock implements IAuthUserService {}

void main() {
  late IUserReceipeRepository userReceipeRepository;
  late IAuthUserService authUserService;

  const AuthUser authUser = AuthUser(
    uid: EntityId('uid'),
    email: 'email',
  );

  setUp(() {
    userReceipeRepository = UserReceipeRepositoryMock();
    authUserService = AuthUserServiceMock();
  });

  group(
    'should return a new list of receipes from the api',
    () {
      test(
        'after 24 hours',
        () async {
          final now = DateTime(2024, 1, 2);
          final currentUserReceipe = UserReceipe(
            receipes: const [
              Receipe(
                name: 'name',
                ingredients: [],
                steps: [],
                averageTime: '',
                totalCalories: '',
              ),
            ],
            lastUpdatedDate: DateTime(2024, 1, 1),
          );
          const newReceipes = <Receipe>[
            Receipe(
              name: 'name',
              ingredients: [],
              steps: [],
              averageTime: '',
              totalCalories: '',
            ),
            Receipe(
              name: 'name1',
              ingredients: [],
              steps: [],
              averageTime: '',
              totalCalories: '',
            ),
          ];

          when(() => authUserService.currentUser).thenReturn(
            authUser,
          );

          when(
            () => userReceipeRepository
                .getReceipesBasedOnUserPreferencesFromFirestore(
              authUser.uid,
            ),
          ).thenAnswer(
            (_) => Future.value(currentUserReceipe),
          );

          when(
            () =>
                userReceipeRepository.getReceipesBasedOnUserPreferencesFromApi(
              authUser.uid,
            ),
          ).thenAnswer(
            (_) => Future.value(newReceipes),
          );

          when(
            () => userReceipeRepository.save(
              authUser.uid,
              UserReceipe(
                receipes: newReceipes,
                lastUpdatedDate: now,
              ),
            ),
          ).thenAnswer(
            (_) => Future.value(),
          );

          final sut = RetrieveReceipeFromApiOneTimePerDayUsecase(
            userReceipeRepository,
            authUserService,
          );
          final receipes = await sut.retrieve(
            now,
          );

          verify(
            () =>
                userReceipeRepository.getReceipesBasedOnUserPreferencesFromApi(
              authUser.uid,
            ),
          ).called(1);
          expect(receipes.length, newReceipes.length);
        },
      );

      test(
        'after more than 24 hours',
        () async {
          final now = DateTime(2024, 1, 3);
          final currentUserReceipe = UserReceipe(
            receipes: const [
              Receipe(
                name: 'name',
                ingredients: [],
                steps: [],
                averageTime: '',
                totalCalories: '',
              ),
            ],
            lastUpdatedDate: DateTime(2024, 1, 1),
          );
          const newReceipes = <Receipe>[
            Receipe(
              name: 'name',
              ingredients: [],
              steps: [],
              averageTime: '',
              totalCalories: '',
            ),
            Receipe(
              name: 'name1',
              ingredients: [],
              steps: [],
              averageTime: '',
              totalCalories: '',
            ),
          ];

          when(() => authUserService.currentUser).thenReturn(
            authUser,
          );

          when(
            () => userReceipeRepository
                .getReceipesBasedOnUserPreferencesFromFirestore(
              authUser.uid,
            ),
          ).thenAnswer(
            (_) => Future.value(currentUserReceipe),
          );

          when(
            () =>
                userReceipeRepository.getReceipesBasedOnUserPreferencesFromApi(
              authUser.uid,
            ),
          ).thenAnswer(
            (_) => Future.value(newReceipes),
          );

          when(
            () => userReceipeRepository.save(
              authUser.uid,
              UserReceipe(
                receipes: newReceipes,
                lastUpdatedDate: now,
              ),
            ),
          ).thenAnswer(
            (_) => Future.value(),
          );

          final sut = RetrieveReceipeFromApiOneTimePerDayUsecase(
            userReceipeRepository,
            authUserService,
          );
          final receipes = await sut.retrieve(
            now,
          );

          verify(
            () =>
                userReceipeRepository.getReceipesBasedOnUserPreferencesFromApi(
              authUser.uid,
            ),
          ).called(1);
          expect(receipes.length, newReceipes.length);
        },
      );

      test(
        'when the user has no receipes in the firestore',
        () async {
          final now = DateTime(2024, 1, 3);
          const newReceipes = <Receipe>[
            Receipe(
              name: 'name',
              ingredients: [],
              steps: [],
              averageTime: '',
              totalCalories: '',
            ),
            Receipe(
              name: 'name1',
              ingredients: [],
              steps: [],
              averageTime: '',
              totalCalories: '',
            ),
          ];

          when(() => authUserService.currentUser).thenReturn(
            authUser,
          );

          when(
            () => userReceipeRepository
                .getReceipesBasedOnUserPreferencesFromFirestore(
              authUser.uid,
            ),
          ).thenAnswer(
            (_) => Future.value(null),
          );

          when(
            () =>
                userReceipeRepository.getReceipesBasedOnUserPreferencesFromApi(
              authUser.uid,
            ),
          ).thenAnswer(
            (_) => Future.value(newReceipes),
          );

          when(
            () => userReceipeRepository.save(
              authUser.uid,
              UserReceipe(
                receipes: newReceipes,
                lastUpdatedDate: now,
              ),
            ),
          ).thenAnswer(
            (_) => Future.value(),
          );

          final sut = RetrieveReceipeFromApiOneTimePerDayUsecase(
            userReceipeRepository,
            authUserService,
          );
          final receipes = await sut.retrieve(
            now,
          );

          verify(
            () =>
                userReceipeRepository.getReceipesBasedOnUserPreferencesFromApi(
              authUser.uid,
            ),
          ).called(1);
          expect(receipes.length, newReceipes.length);
        },
      );
    },
  );

  test(
    'should return the old list of receipes from the firestore before 24 hours',
    () async {
      final now = DateTime(2024, 1, 1);
      final currentUserReceipe = UserReceipe(
        receipes: const [
          Receipe(
            name: 'name',
            ingredients: [],
            steps: [],
            averageTime: '',
            totalCalories: '',
          ),
        ],
        lastUpdatedDate: DateTime(2024, 1, 1),
      );

      when(() => authUserService.currentUser).thenReturn(
        authUser,
      );

      when(
        () => userReceipeRepository
            .getReceipesBasedOnUserPreferencesFromFirestore(
          authUser.uid,
        ),
      ).thenAnswer(
        (_) => Future.value(currentUserReceipe),
      );

      final sut = RetrieveReceipeFromApiOneTimePerDayUsecase(
        userReceipeRepository,
        authUserService,
      );
      final receipes = await sut.retrieve(
        now,
      );

      verifyNever(
        () => userReceipeRepository.getReceipesBasedOnUserPreferencesFromApi(
          authUser.uid,
        ),
      );
      verifyNever(
        () => userReceipeRepository.save(
          authUser.uid,
          UserReceipe(
            receipes: const [],
            lastUpdatedDate: now,
          ),
        ),
      );
      expect(
        receipes.length,
        currentUserReceipe.receipes.length,
      );
    },
  );
}
