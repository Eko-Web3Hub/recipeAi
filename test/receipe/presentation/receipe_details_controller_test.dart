import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository_v2.dart';
import 'package:recipe_ai/receipe/presentation/receipe_details_controller.dart';
import 'package:recipe_ai/user_account/domain/models/user_account_meta_data.dart';
import 'package:recipe_ai/user_account/domain/repositories/user_account_meta_data_repository.dart';
import 'package:recipe_ai/utils/constant.dart';

class AuthUserServiceMock extends Mock implements IAuthUserService {}

class UserAccountMetaDataRepositoryMock extends Mock
    implements IUserAccountMetaDataRepository {}

class UserReceipeRepositoryV2Mock extends Mock
    implements IUserReceipeRepositoryV2 {}

void main() {
  late IAuthUserService authUserService;
  late IUserAccountMetaDataRepository userAccountMetaDataRepository;
  late IUserReceipeRepositoryV2 userReceipeRepositoryV2;

  const receipeId = EntityId('1');
  const userSharingUid = EntityId('sharingUid');
  const authUser = AuthUser(uid: EntityId('uid'), email: 'test@gmail.com');

  const receipeEn = Receipe(
    name: 'nameEn',
    ingredients: [],
    steps: [],
    averageTime: '',
    totalCalories: '',
  );
  const receipeFr = Receipe(
    name: 'nameFr',
    ingredients: [],
    steps: [],
    averageTime: '',
    totalCalories: '',
  );

  final userRecipe = UserRecipeV2(
    id: receipeId,
    receipeFr: receipeFr,
    receipeEn: receipeEn,
    createdDate: DateTime(2024, 1, 1),
  );

  setUp(() {
    authUserService = AuthUserServiceMock();
    userAccountMetaDataRepository = UserAccountMetaDataRepositoryMock();
    userReceipeRepositoryV2 = UserReceipeRepositoryV2Mock();

    when(() => authUserService.currentUser).thenReturn(authUser);
  });

  ReceipeDetailsController buildSut() {
    return ReceipeDetailsController(
      receipeId,
      AppLanguage.en,
      userSharingUid,
      0,
      authUserService,
      userAccountMetaDataRepository,
      userReceipeRepositoryV2,
    );
  }

  blocTest<ReceipeDetailsController, ReceipeDetailsState>(
    'should load the receipe details in english by default',
    build: () => buildSut(),
    setUp: () {
      when(() => userReceipeRepositoryV2.getRecipeByName(
            AppLanguage.en,
            receipeId,
            userSharingUid,
          )).thenAnswer((_) => Future.value(userRecipe));
      when(() => userAccountMetaDataRepository.watchUserAccount(authUser.uid))
          .thenAnswer((_) => Stream.value(null));
    },
    expect: () => [
      ReceipeDetailsState.loaded(userRecipe.receipeEn, userRecipe),
    ],
  );

  blocTest<ReceipeDetailsController, ReceipeDetailsState>(
    'should load the receipe details in the user account language (fr)',
    build: () => buildSut(),
    setUp: () {
      when(() => userReceipeRepositoryV2.getRecipeByName(
            AppLanguage.en,
            receipeId,
            userSharingUid,
          )).thenAnswer((_) => Future.value(userRecipe));
      when(() => userAccountMetaDataRepository.watchUserAccount(authUser.uid))
          .thenAnswer(
        (_) => Stream.value(
          const UserAccountMetaData(
            appLanguage: AppLanguage.fr,
            lastLogin: null,
          ),
        ),
      );
    },
    expect: () => [
      ReceipeDetailsState.loaded(userRecipe.receipeFr, userRecipe),
    ],
  );

  blocTest<ReceipeDetailsController, ReceipeDetailsState>(
    'should load the receipe details from the fromReceipe constructor',
    build: () => ReceipeDetailsController.fromReceipe(
      userRecipe,
      authUserService,
      userAccountMetaDataRepository,
      userReceipeRepositoryV2,
    ),
    setUp: () {
      when(() => userAccountMetaDataRepository.watchUserAccount(authUser.uid))
          .thenAnswer((_) => Stream.value(null));
    },
    verify: (bloc) {
      expect(
        bloc.state,
        ReceipeDetailsState.loaded(userRecipe.receipeEn, userRecipe),
      );
    },
  );
}
