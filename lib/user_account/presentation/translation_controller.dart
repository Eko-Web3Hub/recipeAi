import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/user_account/domain/models/user_account_meta_data.dart';
import 'package:recipe_ai/user_account/domain/repositories/user_account_meta_data_repository.dart';
import 'package:recipe_ai/utils/constant.dart';

abstract class TranslationState extends Equatable {
  const TranslationState();

  @override
  List<Object> get props => [];
}

class TranslationInitial extends TranslationState {
  const TranslationInitial();
}

class TranslationLoaded extends TranslationState {
  const TranslationLoaded(
    this.appLanguage,
  );

  final AppLanguage appLanguage;

  @override
  List<Object> get props => [];
}

class TranslationController extends Cubit<TranslationState> {
  TranslationController(
    this._languages,
    this.defaultLanguage,
    this._userAccountMetaDataRepository,
    this._authUserService,
  ) : super(const TranslationInitial()) {
    _init();
  }

  void _init() async {
    _currentLanguage = defaultLanguage;
    final uid = _authUserService.currentUser!.uid;
    _userAccountMetaData =
        await _userAccountMetaDataRepository.getUserAccount(uid);

    if (_userAccountMetaData != null &&
        _userAccountMetaData!.appLanguage != null) {
      _currentLanguage = _userAccountMetaData!.appLanguage!;
    }

    emit(TranslationLoaded(_currentLanguage));
  }

  AppLocalizations get currentLanguage => _languages[_currentLanguage]!;

  UserAccountMetaData? _userAccountMetaData;
  late AppLanguage _currentLanguage;
  final Map<AppLanguage, AppLocalizations> _languages;
  final AppLanguage defaultLanguage;
  final IUserAccountMetaDataRepository _userAccountMetaDataRepository;
  final IAuthUserService _authUserService;
}
