import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/user_preference_repository.dart';
import 'package:recipe_ai/user_preferences/presentation/user_preference_update_btn_controller.dart';

class AuthUserService extends Mock implements IAuthUserService {}

class UserPreferenceRepository extends Mock
    implements IUserPreferenceRepository {}

void main() {
  late IAuthUserService authUserService;
  late IUserPreferenceRepository userPreferenceRepository;
  const authUser = AuthUser(
    uid: EntityId('uid'),
    email: 'email@gmail.com',
  );

  setUp(() {
    authUserService = AuthUserService();
    userPreferenceRepository = UserPreferenceRepository();

    when(() => authUserService.currentUser).thenReturn(authUser);
  });

  UserPreferenceUpdateBtnController build() =>
      UserPreferenceUpdateBtnController(
        authUserService,
        userPreferenceRepository,
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
      bloc.update(const UserPreference({}));
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
      );
    },
    expect: () => [
      UserPreferenceUpdateBtnLoading(),
      HasNotChangedUserPreference(),
    ],
  );
}
