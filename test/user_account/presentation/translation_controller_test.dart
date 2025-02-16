import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/user_account/domain/models/user_account_meta_data.dart';
import 'package:recipe_ai/user_account/domain/repositories/user_account_meta_data_repository.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/constant.dart';

class UserAccountMetaDataRepository extends Mock
    implements IUserAccountMetaDataRepository {}

class AuthUserServiceMock extends Mock implements IAuthUserService {}

void main() {
  late IUserAccountMetaDataRepository userAccountMetaDataRepository;
  late IAuthUserService authUserService;

  const AuthUser authUser = AuthUser(
    uid: EntityId('uid'),
    email: 'email@gmail.com',
  );

  setUp(() {
    userAccountMetaDataRepository = UserAccountMetaDataRepository();
    authUserService = AuthUserServiceMock();

    when(() => authUserService.currentUser).thenReturn(
      authUser,
    );
  });

  TranslationController sut(String language) => TranslationController(
        appLanguages,
        appLanguageFromString(language),
        userAccountMetaDataRepository,
        authUserService,
      );

  blocTest<TranslationController, TranslationState>(
    'should be in initial state',
    build: () => sut('en'),
    setUp: () {
      when(() => userAccountMetaDataRepository.getUserAccount(authUser.uid))
          .thenAnswer(
        (_) => Completer<UserAccountMetaData>().future,
      );
    },
    verify: (bloc) {
      expect(
        bloc.state,
        equals(
          const TranslationInitial(),
        ),
      );
    },
  );

  blocTest<TranslationController, TranslationState>(
    'should initialize the app language to the default language',
    build: () => sut('en'),
    setUp: () {
      when(
        () => userAccountMetaDataRepository.getUserAccount(authUser.uid),
      ).thenAnswer(
        (_) => Future.value(),
      );
    },
    expect: () => [
      const TranslationLoaded(
        AppLanguage.en,
      ),
    ],
  );

  blocTest<TranslationController, TranslationState>(
    'should initialize the app language to the user account language',
    build: () => sut('en'),
    setUp: () {
      when(
        () => userAccountMetaDataRepository.getUserAccount(authUser.uid),
      ).thenAnswer(
        (_) => Future.value(
          const UserAccountMetaData(
            appLanguage: AppLanguage.fr,
          ),
        ),
      );
    },
    expect: () => [
      const TranslationLoaded(
        AppLanguage.fr,
      ),
    ],
  );

  blocTest<TranslationController, TranslationState>(
    'should initialize the app language with the default language when the user is not yet authenticated',
    build: () => sut('en'),
    setUp: () {
      when(() => authUserService.currentUser).thenReturn(
        null,
      );
    },
    verify: (bloc) {
      expect(
        bloc.state,
        equals(
          const TranslationLoaded(
            AppLanguage.en,
          ),
        ),
      );
    },
  );

  group(
    'currentLanguage method',
    () {
      group('when the user is not authenticated', () {
        setUp(() {
          when(() => authUserService.currentUser).thenReturn(
            null,
          );
        });
        test(
          'should return the default current language (en) ',
          () {
            final controller = sut('en');

            expect(
              controller.currentLanguage,
              equals(
                appLanguages[AppLanguage.en]!,
              ),
            );
          },
        );

        test(
          'should return the default current language (fr) ',
          () {
            final controller = sut('fr');

            expect(
              controller.currentLanguage,
              equals(
                appLanguages[AppLanguage.fr]!,
              ),
            );
          },
        );
      });

      test(
        'should return the current language from the user account (fr)',
        () async {
          when(
            () => userAccountMetaDataRepository.getUserAccount(authUser.uid),
          ).thenAnswer(
            (_) => Future.value(
              const UserAccountMetaData(
                appLanguage: AppLanguage.fr,
              ),
            ),
          );

          final controller = sut('en');

          await pumpEventQueue();

          expect(
            controller.currentLanguage,
            equals(
              appLanguages[AppLanguage.fr]!,
            ),
          );
        },
      );

      test(
        'should return the current language from the user account (en)',
        () async {
          when(
            () => userAccountMetaDataRepository.getUserAccount(authUser.uid),
          ).thenAnswer(
            (_) => Future.value(
              const UserAccountMetaData(
                appLanguage: AppLanguage.en,
              ),
            ),
          );

          final controller = sut('en');

          await pumpEventQueue();

          expect(
            controller.currentLanguage,
            equals(
              appLanguages[AppLanguage.en]!,
            ),
          );
        },
      );
    },
  );
}
