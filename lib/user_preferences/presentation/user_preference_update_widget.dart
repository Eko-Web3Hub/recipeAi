import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/presentation/components/main_btn.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference_question.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/user_preference_quizz_repository.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/user_preference_repository.dart';
import 'package:recipe_ai/user_preferences/presentation/components/custom_progress.dart';
import 'package:recipe_ai/user_preferences/presentation/user_preference_question_list.dart';
import 'package:recipe_ai/user_preferences/presentation/user_preference_update_controller.dart';
import 'package:recipe_ai/utils/app_text.dart';
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

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: horizontalScreenPadding,
              ),
              child: _DisplayUserPreferenceQuiz(
                questions:
                    (userPreferenceUpdateState as UserPreferenceUpdateLoaded)
                        .userPreferenceQuestion,
              ),
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
  int _currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Gap(20),
        Expanded(
          child: UserPreferenceQuestionList(
            questions: widget.questions,
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPageIndex = index;
              });
            },
          ),
        ),
        Row(
          children: [
            Visibility(
              visible: _currentPageIndex != 0,
              child: Expanded(
                child: MainBtn(
                  text: AppText.previous,
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  },
                ),
              ),
            ),
            const Gap(10.0),
            Expanded(
              child: MainBtn(
                onPressed: _currentPageIndex == widget.questions.length - 1
                    ? null
                    : () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      },
                text: AppText.next,
              ),
            ),
          ],
        ),
        const Gap(31.0),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
