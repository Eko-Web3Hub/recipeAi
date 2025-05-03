import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/user_personnal_info_service.dart';
import 'package:recipe_ai/utils/safe_emit.dart';

class EmailLoader extends Cubit<String?> {
  EmailLoader(
    this._userPersonnalInfoService,
  ) : super(null) {
    _load();
  }

  void _load() async {
    final userPersonalInfo = await _userPersonnalInfoService.get();
    if (userPersonalInfo == null) {
      safeEmit(null);
      return;
    }

    safeEmit(userPersonalInfo.email);
  }

  final IUserPersonnalInfoService _userPersonnalInfoService;
}
