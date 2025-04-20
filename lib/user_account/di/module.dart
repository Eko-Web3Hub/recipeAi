import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/di/module.dart';
import 'package:recipe_ai/user_account/application/user_account_metadata_service.dart';
import 'package:recipe_ai/user_account/domain/repositories/user_account_meta_data_repository.dart';
import 'package:recipe_ai/user_account/infrastructure/repositories/user_account_meta_data_repository.dart';

class UserAccountModule implements IDiModule {
  const UserAccountModule();

  @override
  void register(DiContainer di) {
    di.registerLazySingleton<IUserAccountMetaDataRepository>(
      () => FirestoreUserAccountMetaRepository(
        di<FirebaseFirestore>(),
      ),
    );

    di.registerFactory<IUserAccountMetaDataService>(
      () => UserAccountMetaDataService(
        di<IUserAccountMetaDataRepository>(),
        di<IAuthUserService>(),
      ),
    );
  }
}
