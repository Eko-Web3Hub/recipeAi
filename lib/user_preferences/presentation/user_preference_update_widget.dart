import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/presentation/components/custom_snack_bar.dart';
import 'package:recipe_ai/auth/presentation/components/main_btn.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/home/presentation/home_screen_controller.dart';
import 'package:recipe_ai/receipe/application/user_recipe_service.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference_question.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/user_preference_quizz_repository.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/user_preference_repository.dart';
import 'package:recipe_ai/user_preferences/presentation/components/custom_progress.dart';
import 'package:recipe_ai/user_preferences/presentation/user_preference_question_list.dart';
import 'package:recipe_ai/user_preferences/presentation/user_preference_update_btn_controller.dart';
import 'package:recipe_ai/user_preferences/presentation/user_preference_update_controller.dart';
import 'package:recipe_ai/utils/constant.dart';

class UserPreferenceUpdateWidget extends StatelessWidget {
  const UserPreferenceUpdateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserPreferenceUpdateController(
        di<IAuthUserService>(),
        di<IUserPreferenceRepository>(),
        di<IUserPreferenceQuizzRepository>(),
        currentUserLanguage: di<TranslationController>().currentLanguageEnum,
      ),
      child: Builder(builder: (context) {
        return BlocBuilder<UserPreferenceUpdateController,
            UserPreferenceUpdateState>(
          builder: (context, userPreferenceUpdateState) {
            if (userPreferenceUpdateState is UserPreferenceUpdateLoading) {
              return const Center(
                child: CustomProgress(
                  color: Colors.black,
                ),
              );
            }

            return _DisplayUserPreferenceQuiz(
              questions:
                  (userPreferenceUpdateState as UserPreferenceUpdateLoaded)
                      .userPreferenceQuestion,
            );
          },
        );
      }),
    );
  }
}

class _DisplayUserPreferenceQuiz extends StatefulWidget {
  const _DisplayUserPreferenceQuiz({
    required this.questions,
  });

  @override
  State<_DisplayUserPreferenceQuiz> createState() =>
      _DisplayUserPreferenceQuizState();

  final List<UserPreferenceQuestion> questions;
}

class _DisplayUserPreferenceQuizState
    extends State<_DisplayUserPreferenceQuiz> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return BlocProvider(
      create: (context) => UserPreferenceUpdateBtnController(
        di<IAuthUserService>(),
        di<IUserPreferenceRepository>(),
        di<IUserRecipeService>(),
      ),
      child: Builder(builder: (context) {
        return BlocListener<UserPreferenceUpdateBtnController,
            UserPreferenceUpdateBtnState>(
          listener: (context, state) {
            if (state is UserPreferenceUpdateBtnSuccess) {
              showSnackBar(
                context,
                appTexts.updateUserPreferenceSuccess,
              );
              context.read<HomeScreenController>().reload();
            } else if (state is HasNotChangedUserPreference) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    appTexts.noChangeInUserPreference,
                    style: GoogleFonts.poppins(),
                  ),
                ),
              );
            }
          },
          child: Column(
            children: [
              const Gap(20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: horizontalScreenPadding),
                  child: UserPreferenceQuestionList(
                    questions: widget.questions,
                    controller: _pageController,
                  ),
                ),
              ),
              BlocBuilder<UserPreferenceUpdateBtnController,
                  UserPreferenceUpdateBtnState>(builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: horizontalScreenPadding,
                  ),
                  child: MainBtn(
                    text: appTexts.update,
                    isLoading: state is UserPreferenceUpdateBtnLoading,
                    onPressed: () {
                      var userPreference = <String, dynamic>{};
                      for (final question in widget.questions) {
                        userPreference = {
                          ...userPreference,
                          ...question.toJson(),
                        };
                      }
                      context.read<UserPreferenceUpdateBtnController>().update(
                            UserPreference(userPreference),
                            DateTime.now(),
                          );
                    },
                  ),
                );
              }),
              const Gap(30.0),
            ],
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
