import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/user_account/domain/models/user_account_meta_data.dart';
import 'package:recipe_ai/user_account/domain/repositories/user_account_meta_data_repository.dart';
import 'package:recipe_ai/utils/constant.dart';

class TranslationController {
  TranslationController(
    this._languages,
    this.defaultLanguage,
    this._userAccountMetaDataRepository,
    this._authUserService,
  ) {
    _init();
  }

  void _init() async {
    _currentLanguage = defaultLanguage;
    if (_authUserService.currentUser == null) {
      return;
    }

    final uid = _authUserService.currentUser!.uid;
    _userAccountMetaData =
        await _userAccountMetaDataRepository.getUserAccount(uid);

    if (_userAccountMetaData != null) {
      _currentLanguage = _userAccountMetaData!.appLanguage;
    }

    _userAccountMetaDataRepository.save(
      uid,
      UserAccountMetaData(appLanguage: _currentLanguage),
    );
  }

  AppLocalizations get currentLanguage => _languages[_currentLanguage]!;

  AppLanguage get currentLanguageEnum => _currentLanguage;

  UserAccountMetaData? _userAccountMetaData;
  late AppLanguage _currentLanguage;
  final Map<AppLanguage, AppLocalizations> _languages;
  final AppLanguage defaultLanguage;
  final IUserAccountMetaDataRepository _userAccountMetaDataRepository;
  final IAuthUserService _authUserService;
}
