import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/di/module.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/user_preference_quizz_repository.dart';

import '../infrastructure/user_preference_quizz_repository.dart';

class UserPreferencesModule implements IDiModule {
  const UserPreferencesModule();

  @override
  void register(DiContainer di) {
    di.registerLazySingleton<IUserPreferenceQuizzRepository>(
      () => FirestoreUserPreferenceQuizzRepository(
        di<FirebaseFirestore>(),
      ),
    );
  }
}
