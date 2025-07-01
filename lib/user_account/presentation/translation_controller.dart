import 'package:flutter/material.dart';
import 'package:recipe_ai/l10n/app_localizations.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/user_account/domain/models/user_account_meta_data.dart';
import 'package:recipe_ai/user_account/domain/repositories/user_account_meta_data_repository.dart';
import 'package:recipe_ai/utils/constant.dart';

class TranslationController extends ChangeNotifier {
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
    final userAccountMetaData =
        await _userAccountMetaDataRepository.getUserAccount(uid);

    if (userAccountMetaData != null) {
      _currentLanguage = userAccountMetaData.appLanguage;
    }

    _userAccountMetaDataRepository.save(
      uid,
      UserAccountMetaData(
        appLanguage: _currentLanguage,
        lastLogin: null,
      ),
    );
  }

  Future<void> saveLanguageWhenNeeded() async {
    final uid = _authUserService.currentUser!.uid;
    final userAccountMetaData = await _userAccountMetaDataRepository
        .getUserAccount(_authUserService.currentUser!.uid);

    if (userAccountMetaData == null) {
      _userAccountMetaDataRepository.save(
        uid,
        UserAccountMetaData(
          appLanguage: _currentLanguage,
          lastLogin: null,
        ),
      );
    } else {
      _currentLanguage = userAccountMetaData.appLanguage;
    }

    notifyListeners();
  }

  Future<void> changeLanguage(String appLanguageKey) async {
    if (currentLanguageEnum.name == appLanguageKey) {
      return;
    }

    _currentLanguage = AppLanguage.values
        .firstWhere((element) => element.name == appLanguageKey);

    final currentUserAccountMetaData = await _userAccountMetaDataRepository
        .getUserAccount(_authUserService.currentUser!.uid);
    final userAccountMetadataUpdated =
        currentUserAccountMetaData!.changeLanguage(
      _currentLanguage,
    );
    _userAccountMetaDataRepository.save(
      _authUserService.currentUser!.uid,
      userAccountMetadataUpdated,
    );

    notifyListeners();
  }

  AppLocalizations get currentLanguage => _languages[_currentLanguage]!;

  AppLanguage get currentLanguageEnum => _currentLanguage;

  late AppLanguage _currentLanguage;
  final Map<AppLanguage, AppLocalizations> _languages;
  final AppLanguage defaultLanguage;
  final IUserAccountMetaDataRepository _userAccountMetaDataRepository;
  final IAuthUserService _authUserService;
}
