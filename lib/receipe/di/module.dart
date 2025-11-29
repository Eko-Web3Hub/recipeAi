import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/di/module.dart';
import 'package:recipe_ai/receipe/application/retrieve_receipe_from_api_one_time_per_day_usecase.dart';
import 'package:recipe_ai/receipe/application/user_recipe_service.dart';
import 'package:recipe_ai/receipe/application/user_recipe_translate_service.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository_v2.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_recipe_translate.dart';
import 'package:recipe_ai/receipe/infrastructure/receipe_repository_v2.dart';
import 'package:recipe_ai/receipe/infrastructure/user_recipe_translate_repository.dart';

class ReceipeModule implements IDiModule {
  const ReceipeModule();

  @override
  void register(DiContainer di) {
    di.registerLazySingleton<IUserReceipeRepositoryV2>(
      () => UserReceipeRepositoryV2(
        di<FirebaseFirestore>(),
        di<Dio>(),
      ),
    );

    di.registerLazySingleton<IUserRecipeTranslateRepository>(
      () => FirestoreUserRecipeTranslateRepository(
        di<FirebaseFirestore>(),
      ),
    );

    di.registerFactory<IUserRecipeService>(() => UserRecipeService(
          di<IUserReceipeRepositoryV2>(),
          di<IAuthUserService>(),
        ));

    di.registerFactory<RetrieveReceipeFromApiOneTimePerDayUsecase>(
      () => RetrieveReceipeFromApiOneTimePerDayUsecase(
        di<IUserReceipeRepository>(),
        di<IAuthUserService>(),
        di<IUserReceipeRepositoryV2>(),
        di<IUserRecipeService>(),
      ),
    );
    di.registerFactory<UserRecipeTranslateService>(
      () => UserRecipeTranslateService.inject(),
    );
  }
}
