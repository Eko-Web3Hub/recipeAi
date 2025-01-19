import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/application/update_user_receipe_usecase.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository.dart';

class UserReceipeRepository extends Mock implements IUserReceipeRepository {}

class AuthUserService extends Mock implements IAuthUserService {}

void main() {
  late IUserReceipeRepository userReceipeRepository;
  late IAuthUserService authUserService;

  const authUser = AuthUser(
    uid: EntityId('uid'),
    email: 'test@gmail.com',
  );
  const receipes = [
    Receipe(
      name: 'name',
      ingredients: [],
      steps: [],
      averageTime: "averageTime",
      totalCalories: "",
    ),
  ];

  setUp(() {
    userReceipeRepository = UserReceipeRepository();
    authUserService = AuthUserService();

    when(() => authUserService.currentUser).thenReturn(authUser);
  });

  test(
    'should update user receipe',
    () async {
      final now = DateTime(2021, 10, 10);

      when(
        () => userReceipeRepository.getReceipesBasedOnUserPreferencesFromApi(
          authUser.uid,
        ),
      ).thenAnswer((_) => Future.value(receipes));

      when(
        () => userReceipeRepository.save(
          authUser.uid,
          UserReceipe(
            receipes: receipes,
            lastUpdatedDate: now,
          ),
        ),
      ).thenAnswer((_) => Future.value());

      final sut = UpdateUserReceipeUsecase(
        userReceipeRepository,
        authUserService,
      );

      await sut.update(now);

      verify(
        () => userReceipeRepository.getReceipesBasedOnUserPreferencesFromApi(
          authUser.uid,
        ),
      ).called(1);
      verify(
        () => userReceipeRepository.save(
          authUser.uid,
          UserReceipe(
            receipes: receipes,
            lastUpdatedDate: now,
          ),
        ),
      ).called(1);
    },
  );
}
