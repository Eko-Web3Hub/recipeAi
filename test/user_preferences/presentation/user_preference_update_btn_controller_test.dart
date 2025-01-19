import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/user_preference_repository.dart';
import 'package:recipe_ai/user_preferences/presentation/user_preference_update_btn_controller.dart';

class AuthUserService extends Mock implements IAuthUserService {}

class UserPreferenceRepository extends Mock
    implements IUserPreferenceRepository {}

class UserReceipeRepository extends Mock implements IUserReceipeRepository {}

void main() {
  late IAuthUserService authUserService;
  late IUserPreferenceRepository userPreferenceRepository;
  late IUserReceipeRepository userReceipeRepository;
  const newUserPreference = UserPreference(
    {
      'Halal': true,
    },
  );
  const authUser = AuthUser(
    uid: EntityId('uid'),
    email: 'email@gmail.com',
  );
  final now = DateTime(2021, 10, 10);

  setUp(() {
    authUserService = AuthUserService();
    userPreferenceRepository = UserPreferenceRepository();
    userReceipeRepository = UserReceipeRepository();

    when(() => authUserService.currentUser).thenReturn(authUser);
  });

  UserPreferenceUpdateBtnController build() =>
      UserPreferenceUpdateBtnController(
        authUserService,
        userPreferenceRepository,
        userReceipeRepository,
      );

  blocTest<UserPreferenceUpdateBtnController, UserPreferenceUpdateBtnState>(
    'should be in initial state',
    build: () => build(),
    verify: (bloc) {
      expect(bloc.state, isA<UserPreferenceUpdateBtnInitial>());
    },
  );

  blocTest<UserPreferenceUpdateBtnController, UserPreferenceUpdateBtnState>(
    'should be in loading state',
    build: () => build(),
    setUp: () {
      when(() => userPreferenceRepository.retrieve(authUser.uid))
          .thenAnswer((_) => Completer<UserPreference>().future);
    },
    act: (bloc) async {
      await pumpEventQueue();
      bloc.update(
        const UserPreference({}),
        now,
      );
    },
    verify: (bloc) {
      expect(bloc.state, isA<UserPreferenceUpdateBtnLoading>());
    },
  );

  blocTest<UserPreferenceUpdateBtnController, UserPreferenceUpdateBtnState>(
    'should not update the user receipe when the user preference has not changed',
    build: () => build(),
    setUp: () {
      when(() => userPreferenceRepository.retrieve(authUser.uid)).thenAnswer(
        (_) => Future.value(
          const UserPreference(
            {
              'Halal': true,
            },
          ),
        ),
      );
    },
    act: (bloc) {
      bloc.update(
        const UserPreference(
          {
            'Halal': true,
          },
        ),
        now,
      );
    },
    expect: () => [
      UserPreferenceUpdateBtnLoading(),
      HasNotChangedUserPreference(),
    ],
  );

  blocTest<UserPreferenceUpdateBtnController, UserPreferenceUpdateBtnState>(
    'should update the user receipe when the user preference has changed',
    build: () => build(),
    setUp: () {
      when(() => userPreferenceRepository.retrieve(authUser.uid)).thenAnswer(
        (_) => Future.value(
          const UserPreference(
            {
              'Halal': false,
            },
          ),
        ),
      );
      when(
        () => userPreferenceRepository.save(
          authUser.uid,
          newUserPreference,
        ),
      ).thenAnswer(
        (_) => Future.value(),
      );
      when(
        () => userReceipeRepository.deleteUserReceipe(authUser.uid),
      ).thenAnswer(
        (_) => Future.value(),
      );
    },
    act: (bloc) {
      bloc.update(
        newUserPreference,
        now,
      );
    },
    verify: (bloc) {
      verify(
        () => userPreferenceRepository.save(
          authUser.uid,
          newUserPreference,
        ),
      ).called(1);
      verify(
        () => userReceipeRepository.deleteUserReceipe(authUser.uid),
      ).called(1);
    },
    expect: () => [
      UserPreferenceUpdateBtnLoading(),
      UserPreferenceUpdateBtnSuccess(),
    ],
  );
}
