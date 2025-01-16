import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/kitchen/presentation/kitchen_inventory_screen.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/user_preference_repository.dart';
import 'package:recipe_ai/user_preferences/presentation/components/custom_progress.dart';
import 'package:recipe_ai/user_preferences/presentation/user_preference_update_controller.dart';
import 'package:recipe_ai/utils/app_text.dart';

class UpdateUserPreferenceScreen extends StatelessWidget {
  const UpdateUserPreferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserPreferenceUpdateController(
        di<IAuthUserService>(),
        di<IUserPreferenceRepository>(),
      ),
      child: Builder(builder: (context) {
        return SafeArea(
          child: Scaffold(
            appBar: KitchenInventoryAppBar(
              arrowLeftOnPressed: () => context.go('/profil-screen'),
              title: AppText.updateUserPreference,
            ),
            body: Column(
              children: [
                BlocBuilder<UserPreferenceUpdateController,
                    UserPreferenceUpdateState>(
                  builder: (context, userPreferenceUpdateState) {
                    if (userPreferenceUpdateState
                        is UserPreferenceUpdateLoading) {
                      return const Expanded(
                        child: Center(
                          child: CustomProgress(
                            color: Colors.black,
                          ),
                        ),
                      );
                    }

                    return SizedBox();
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
