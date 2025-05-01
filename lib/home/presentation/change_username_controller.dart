import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/user_personnal_info_service.dart';
import 'package:recipe_ai/utils/safe_emit.dart';

abstract class ChangeUsernameState {}

class ChangeUsernameInitial extends ChangeUsernameState {}

class ChangeUsernameLoading extends ChangeUsernameState {}

class ChangeUsernameLoaded extends ChangeUsernameState {
  final String username;
  final bool isChanged;
  ChangeUsernameLoaded(this.username, {this.isChanged = false});
}

class ChangeUsernameController extends Cubit<ChangeUsernameState> {
  ChangeUsernameController(
    this._userPersonnalInfoService,
  ) : super(
          ChangeUsernameInitial(),
        ) {
    _load();
  }

  void _load() async {
    final userPersonalInfo = await _userPersonnalInfoService.get();
    safeEmit(ChangeUsernameLoaded(userPersonalInfo?.name ?? ''));
  }

  Future<void> changeUsername(String username) async {
    assert(state is ChangeUsernameLoaded);

    safeEmit(ChangeUsernameLoading());
    await _userPersonnalInfoService.changeUsername(username);
    safeEmit(ChangeUsernameLoaded(
      username,
      isChanged: true,
    ));
  }

  final IUserPersonnalInfoService _userPersonnalInfoService;
}
