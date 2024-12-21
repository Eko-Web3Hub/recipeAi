import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipe_ai/auth/application/auth_service.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/application/register_usecase.dart';
import 'package:recipe_ai/auth/application/user_personnal_info_service.dart';
import 'package:recipe_ai/auth/domain/repositories/user_personnal_info_repository.dart';
import 'package:recipe_ai/auth/infrastructure/user_personnal_info_repository.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/di/module.dart';

class AuthModule implements IDiModule {
  const AuthModule();

  @override
  void register(DiContainer di) {
    di.registerLazySingleton<IUserPersonnalInfoRepository>(
      () => FirestoreUserPersonnalInfoRepository(
        di<FirebaseFirestore>(),
      ),
    );
    di.registerFactory<IFirebaseAuth>(
      () => FirebaseAuthProd(
        di<FirebaseAuth>(),
      ),
    );
    di.registerFactory<IAuthService>(
      () => AuthService(
        di<IFirebaseAuth>(),
      ),
    );

    di.registerFactory<IAuthUserService>(
      () => AuthUserService(
        di<IFirebaseAuth>(),
      ),
    );
    di.registerFactory(
      () => RegisterUsecase(
        di<IAuthService>(),
        di<IAuthUserService>(),
        di<IUserPersonnalInfoRepository>(),
      ),
    );

    di.registerFactory<IUserPersonnalInfoService>(
      () => UserPersonnalInfoService(
        di<IUserPersonnalInfoRepository>(),
        di<IAuthUserService>(),
      ),
    );
  }
}
