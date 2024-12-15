import 'package:dio/dio.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/di/module.dart';
import 'package:recipe_ai/receipe/application/retrieve_receipe_from_api_one_time_per_day_usecase.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository.dart';
import 'package:recipe_ai/receipe/infrastructure/receipe_repository.dart';

class ReceipeModule implements IDiModule {
  const ReceipeModule();

  @override
  void register(DiContainer di) {
    di.registerLazySingleton<IUserReceipeRepository>(
      () => UserReceipeRepository(dio: di<Dio>()),
    );

    di.registerFactory(
      () => RetrieveReceipeFromApiOneTimePerDayUsecase(
        di<IUserReceipeRepository>(),
        di<IAuthUserService>(),
      ),
    );
  }
}
