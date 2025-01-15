import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/di/module.dart';
import 'package:recipe_ai/utils/remote_config_data_source.dart';

class CoreModule implements IDiModule {
  const CoreModule();

  @override
  void register(DiContainer di) {
    di.registerLazySingleton<FirebaseAuth>(
      () => FirebaseAuth.instance,
    );
    di.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance,
    );
    di.registerLazySingleton<FirebaseRemoteConfig>(
      () => FirebaseRemoteConfig.instance,
    );
    di.registerLazySingleton<Dio>(
      () => Dio(BaseOptions(headers: {
        'Content-Type': 'application/json',
        'accept': 'application/json',
      })),
    );

    di.registerLazySingleton<RemoteConfigDataSource>(
      () => RemoteConfigDataSource(
        di<FirebaseRemoteConfig>(),
      ),
    );
  }
}
