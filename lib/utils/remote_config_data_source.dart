import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigDataSource {
  const RemoteConfigDataSource(
    this._client,
  );

  final FirebaseRemoteConfig _client;

  Future<void> initializeFirebaseRemoteConfig(
    Map<String, dynamic> defaultValues,
  ) async {
    await _client.setDefaults(defaultValues);
    if (kDebugMode) {
      await _client.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(seconds: 1),
      ));
    } else {
      await _client.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 12),
      ));
    }

    await _client.fetchAndActivate();
  }

  bool getBool(String key) {
    return _client.getBool(key);
  }

  String getString(String key) {
    return _client.getString(key);
  }
}
