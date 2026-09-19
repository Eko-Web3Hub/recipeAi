import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/application/user_personnal_info_service.dart';
import 'package:recipe_ai/auth/domain/model/user_personnal_info.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/home/presentation/profile/profile_controller.dart';
import 'package:recipe_ai/receipe/application/user_recipe_service.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/user_preferences/domain/model/onboarding_step.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/onboarding_quizz_repository.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/user_preference_repository.dart';

class _AuthUserServiceMock extends Mock implements IAuthUserService {}

class _UserPersonnalInfoServiceMock extends Mock
    implements IUserPersonnalInfoService {}

class _UserPreferenceRepositoryMock extends Mock
    implements IUserPreferenceRepository {}

class _OnboardingQuizzRepositoryMock extends Mock
    implements IOnboardingQuizzRepository {}

class _UserRecipeServiceMock extends Mock implements IUserRecipeService {}

void main() {
  late IAuthUserService authUserService;
  late IUserPersonnalInfoService userPersonnalInfoService;
  late IUserPreferenceRepository userPreferenceRepository;
  late IOnboardingQuizzRepository onboardingQuizzRepository;
  late IUserRecipeService userRecipeService;
  late StreamController<List<UserRecipeV2>> favorites;

  const uid = EntityId('uid');
  const preferences = UserPreference({'vegetarian': true});
  const steps = <OnboardingStep>[];

  setUpAll(() {
    registerFallbackValue(uid);
  });

  setUp(() {
    authUserService = _AuthUserServiceMock();
    userPersonnalInfoService = _UserPersonnalInfoServiceMock();
    userPreferenceRepository = _UserPreferenceRepositoryMock();
    onboardingQuizzRepository = _OnboardingQuizzRepositoryMock();
    userRecipeService = _UserRecipeServiceMock();
    favorites = StreamController<List<UserRecipeV2>>();

    when(
      () => authUserService.currentUser,
    ).thenReturn(const AuthUser(uid: uid, email: 'kemi@mail.com'));
    when(() => userPersonnalInfoService.watch()).thenAnswer(
      (_) => Stream.value(const UserPersonnalInfo(uid: uid, name: 'Kemi')),
    );
    when(
      () => userPreferenceRepository.retrieve(uid),
    ).thenAnswer((_) async => preferences);
    when(
      () => onboardingQuizzRepository.retrieve(),
    ).thenAnswer((_) async => steps);
    when(
      () => userRecipeService.countGeneratedRecipes(),
    ).thenAnswer((_) async => 42);
    when(
      () => userRecipeService.watchAllSavedReceipes(),
    ).thenAnswer((_) => favorites.stream);
  });

  tearDown(() => favorites.close());

  ProfileController buildSut() => ProfileController(
    authUserService,
    userPersonnalInfoService,
    userPreferenceRepository,
    onboardingQuizzRepository,
    userRecipeService,
  );

  blocTest<ProfileController, ProfileState>(
    'loads the name, the preferences and both counts',
    build: buildSut,
    act: (_) => favorites.add(const []),
    wait: const Duration(milliseconds: 10),
    verify: (sut) => expect(
      sut.state,
      const ProfileState(
        name: 'Kemi',
        preferences: preferences,
        steps: steps,
        generatedCount: 42,
        favoriteCount: 0,
      ),
    ),
  );

  blocTest<ProfileController, ProfileState>(
    'refresh reads the generated count again',
    build: buildSut,
    act: (sut) async {
      await Future<void>.delayed(Duration.zero);
      when(
        () => userRecipeService.countGeneratedRecipes(),
      ).thenAnswer((_) async => 43);
      await sut.refresh();
    },
    verify: (sut) {
      expect(sut.state.generatedCount, 43);
      verify(() => userPreferenceRepository.retrieve(uid)).called(2);
    },
  );

  blocTest<ProfileController, ProfileState>(
    'keeps the stats empty when they cannot be read',
    setUp: () {
      when(
        () => userRecipeService.countGeneratedRecipes(),
      ).thenThrow(Exception('offline'));
      when(
        () => userPreferenceRepository.retrieve(uid),
      ).thenThrow(Exception('offline'));
    },
    build: buildSut,
    wait: const Duration(milliseconds: 10),
    verify: (sut) {
      expect(sut.state.generatedCount, isNull);
      expect(sut.state.preferences, isNull);
      expect(sut.state.name, 'Kemi');
    },
  );
}
