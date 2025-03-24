import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

abstract class ILocalStorageRepository {
  Future<void> setBool(String key, bool value);
  Future<bool?> getBool(String key);
}

class LocalStorageRepository implements ILocalStorageRepository {
  LocalStorageRepository()
      : _sharedPreferenceInstanceCompleter = Completer<SharedPreferences>() {
    _initSharedPreferences();
  }

  _initSharedPreferences() async {
    final sharedPrefrenceInstance = await SharedPreferences.getInstance();
    _sharedPreferenceInstanceCompleter.complete(sharedPrefrenceInstance);
  }

  @override
  Future<void> setBool(String key, bool value) async {
    final sharedPrefrenceInstance =
        await _sharedPreferenceInstanceCompleter.future;

    await sharedPrefrenceInstance.setBool(key, value);
  }

  @override
  Future<bool?> getBool(String key ) async{
 final sharedPrefrenceInstance =
        await _sharedPreferenceInstanceCompleter.future;

        return sharedPrefrenceInstance.getBool(key);
  }

  final Completer<SharedPreferences> _sharedPreferenceInstanceCompleter;
}
