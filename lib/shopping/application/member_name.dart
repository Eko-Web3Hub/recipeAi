import 'dart:developer';

import 'package:recipe_ai/auth/application/user_personnal_info_service.dart';

/// The name the current user shows to the other members of a list: their
/// Eat'Easy username, or an empty string when it cannot be read (the
/// avatar then falls back on a generic icon).
Future<String> currentMemberName(IUserPersonnalInfoService service) async {
  try {
    return (await service.get())?.name.trim() ?? '';
  } catch (error) {
    log('Username failed to load: $error');
    return '';
  }
}
