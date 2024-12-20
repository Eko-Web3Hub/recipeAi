import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/di/module.dart';

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
    di.registerLazySingleton<Dio>(
      () => Dio(BaseOptions(headers: {
        'Content-Type': 'application/json',
        'accept': 'application/json',
      })),
    );
  }
}
