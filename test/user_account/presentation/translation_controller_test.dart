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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_fr.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_en.dart';

class UserAccountMetaDataRepository extends Mock
    implements IUserAccountMetaDataRepository {}

class AuthUserServiceMock extends Mock implements IAuthUserService {}

void main() {
  late IUserAccountMetaDataRepository userAccountMetaDataRepository;
  late IAuthUserService authUserService;
  final languages = <AppLanguage, AppLocalizations>{
    AppLanguage.fr: AppLocalizationsFr(),
    AppLanguage.en: AppLocalizationsEn(),
  };
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

  TranslationController sut() => TranslationController(
        languages,
        appLanguageFromString('en'),
        userAccountMetaDataRepository,
        authUserService,
      );

  blocTest<TranslationController, TranslationState>(
    'should be in initial state',
    build: () => sut(),
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
    build: () => sut(),
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
    build: () => sut(),
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
}
