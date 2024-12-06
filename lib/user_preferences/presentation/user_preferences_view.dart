import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:recipe_ai/auth/presentation/components/main_btn.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/user_preference_quizz_repository.dart';
import 'package:recipe_ai/user_preferences/presentation/components/custom_circular_loader.dart';
import 'package:recipe_ai/user_preferences/presentation/user_preference_question_list.dart';
import 'package:recipe_ai/user_preferences/presentation/user_preference_quizz_controller.dart';
import 'package:recipe_ai/utils/app_text.dart';
import 'package:recipe_ai/utils/constant.dart';

class UserPreferencesView extends StatelessWidget {
  const UserPreferencesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserPreferenceQuizzController(
        di.get<IUserPreferenceQuizzRepository>(),
      ),
      child: Builder(
        builder: (context) {
          return Scaffold(
            body: SafeArea(
              child: BlocBuilder<UserPreferenceQuizzController,
                  UserPreferenceQuizzState>(
                builder: (context, state) {
                  if (state is UserPreferenceQuizzLoading) {
                    return const Center(
                      child: CustomCircularLoader(),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: horizontalScreenPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Gap(10),
                        Expanded(
                          child: UserPreferenceQuestionList(
                            questions:
                                (state as UserPreferenceQuizzLoaded).questions,
                          ),
                        ),
                        MainBtn(
                          text: AppText.next,
                          showRightIcon: true,
                          onPressed: () {},
                        ),
                        const Gap(31.0),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
