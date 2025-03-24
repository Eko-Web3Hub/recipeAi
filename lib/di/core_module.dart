import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:recipe_ai/analytics/analytics_repository.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/di/module.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/function_caller.dart';
import 'package:recipe_ai/utils/remote_config_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoreModule implements IDiModule {
  const CoreModule();

  @override
  void register(DiContainer di) {
    di.registerSingleton<IAnalyticsRepository>(
      AnalyticsRepository(FirebaseAnalytics.instance),
    );
    di.registerSingleton<FirebaseAuth>(
      FirebaseAuth.instance,
    );
    di.registerSingleton<FirebaseFirestore>(
      FirebaseFirestore.instance,
    );
    di.registerSingleton<FirebaseRemoteConfig>(
      FirebaseRemoteConfig.instance,
    );
    di.registerLazySingleton<Dio>(
      () => Dio(dioOption),
    );

    di.registerLazySingleton<RemoteConfigDataSource>(
      () => RemoteConfigDataSource(
        di<FirebaseRemoteConfig>(),
      ),
    );

    di.registerFactory<FunctionsCaller>(
      () => FunctionsCaller.inject(),
    );

    di.registerSingletonAsync<ILocalStorageRepository>(
      () async => LocalStorageRepository(),
    );
  }
}

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
