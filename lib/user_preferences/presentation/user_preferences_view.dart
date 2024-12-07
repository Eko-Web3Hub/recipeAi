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

class UserPreferencesView extends StatefulWidget {
  const UserPreferencesView({super.key});

  @override
  State<UserPreferencesView> createState() => _UserPreferencesViewState();
}

class _UserPreferencesViewState extends State<UserPreferencesView> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

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

                  final questions =
                      (state as UserPreferenceQuizzLoaded).questions;

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
                            questions: questions,
                            controller: _pageController,
                            onPageChanged: (index) {
                              print(index);
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
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeIn,
                                    );
                                  },
                                ),
                              ),
                            ),
                            const Gap(10.0),
                            Expanded(
                              child: MainBtn(
                                text: AppText.next,
                                showRightIcon: _currentPageIndex == 0,
                                onPressed: () {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeIn,
                                  );
                                },
                              ),
                            ),
                          ],
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
