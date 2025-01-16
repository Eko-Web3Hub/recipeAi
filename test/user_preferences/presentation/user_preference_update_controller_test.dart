import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/user_preference_repository.dart';
import 'package:recipe_ai/user_preferences/presentation/user_preference_update_controller.dart';

class AuthUserServiceMock extends Mock implements IAuthUserService {}

class UserPreferenceRepositoryMock extends Mock
    implements IUserPreferenceRepository {}

void main() {
  late IAuthUserService authUserService;
  late IUserPreferenceRepository userPreferenceRepository;
  const authUser = AuthUser(
    uid: EntityId('uid'),
    email: 'test@gmail.com',
  );
  const userPreference = UserPreference({
    'French': true,
    'Italian': false,
    'Lactose-Free': true,
  });

  setUp(() {
    authUserService = AuthUserServiceMock();
    userPreferenceRepository = UserPreferenceRepositoryMock();

    when(() => authUserService.currentUser).thenAnswer(
      (_) => authUser,
    );
  });

  UserPreferenceUpdateController buildSut() => UserPreferenceUpdateController(
        authUserService,
        userPreferenceRepository,
      );

  blocTest<UserPreferenceUpdateController, UserPreferenceUpdateState>(
    'should be in loading state initially',
    build: () => buildSut(),
    setUp: () {
      when(() => userPreferenceRepository.retrieve(authUser.uid)).thenAnswer(
        (_) => Completer<UserPreference>().future,
      );
    },
    verify: (bloc) => {
      expect(
        bloc.state,
        UserPreferenceUpdateLoading(),
      ),
    },
  );

  blocTest<UserPreferenceUpdateController, UserPreferenceUpdateState>(
    'should load default user preference',
    build: () => buildSut(),
    setUp: () {
      when(() => userPreferenceRepository.retrieve(authUser.uid)).thenAnswer(
        (_) => Future.value(userPreference),
      );
    },
    expect: () => [
      UserPreferenceUpdateLoaded(userPreference),
    ],
  );
}
