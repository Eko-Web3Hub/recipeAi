import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/chat_ai/application/find_recipe_with_image_usecase.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/di/module.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository_v2.dart';

class ChatAiModule implements IDiModule {
  const ChatAiModule();

  @override
  void register(DiContainer di) {
    di.registerFactory<FindRecipeWithImageUsecase>(
      () => FindRecipeWithImageUsecase(
        di<IUserReceipeRepositoryV2>(),
        di<IAuthUserService>(),
      ),
    );
  }
}
