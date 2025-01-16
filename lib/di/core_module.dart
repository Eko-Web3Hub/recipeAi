import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/di/module.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/remote_config_data_source.dart';

class CoreModule implements IDiModule {
  const CoreModule();

  @override
  void register(DiContainer di) {
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
  }
}
