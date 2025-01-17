import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/user_preference_quizz_repository.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/user_preference_repository.dart';
import 'package:recipe_ai/user_preferences/presentation/components/custom_progress.dart';
import 'package:recipe_ai/user_preferences/presentation/user_preference_update_controller.dart';

class UserPreferenceUpdateWidget extends StatelessWidget {
  const UserPreferenceUpdateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserPreferenceUpdateController(
        di<IAuthUserService>(),
        di<IUserPreferenceRepository>(),
        di<IUserPreferenceQuizzRepository>(),
      ),
      child: Builder(builder: (context) {
        return Column(
          children: [
            BlocBuilder<UserPreferenceUpdateController,
                UserPreferenceUpdateState>(
              builder: (context, userPreferenceUpdateState) {
                if (userPreferenceUpdateState is UserPreferenceUpdateLoading) {
                  return const Expanded(
                    child: Center(
                      child: CustomProgress(
                        color: Colors.black,
                      ),
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
          ],
        );
      }),
    );
  }
}
