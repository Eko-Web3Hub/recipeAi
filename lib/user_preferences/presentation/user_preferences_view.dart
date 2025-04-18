import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/presentation/components/main_btn.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/notification/presentation/notification_dialog.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/user_preferences/application/user_preference_service.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/user_preference_quizz_repository.dart';
import 'package:recipe_ai/user_preferences/presentation/components/custom_circular_loader.dart';
import 'package:recipe_ai/user_preferences/presentation/user_preference_submit_btn_controller.dart';
import 'package:recipe_ai/user_preferences/presentation/user_preference_question_list.dart';
import 'package:recipe_ai/user_preferences/presentation/user_preference_quizz_controller.dart';
import 'package:recipe_ai/utils/constant.dart';

class UserPreferencesView extends StatefulWidget {
  const UserPreferencesView({super.key});

  @override
  State<UserPreferencesView> createState() => _UserPreferencesViewState();
}

class _UserPreferencesViewState extends State<UserPreferencesView>
    with AutomaticKeepAliveClientMixin {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;
  final appTexts = di<TranslationController>().currentLanguage;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<bool?> showNotificationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          insetPadding: const EdgeInsets.symmetric(horizontal: 33),
          content: const NotificationDialog(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
        );
      },
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider(
      create: (context) => UserPreferenceQuizzController(
        di.get<IUserPreferenceQuizzRepository>(),
        currentUserLanguage: di<TranslationController>().currentLanguageEnum,
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
                                  text: appTexts.previous,
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
                              child: Center(
                                child: BlocProvider(
                                  create: (context) =>
                                      UserPreferenceSubmitBtnController(
                                    di<UserPreferenceService>(),
                                    di<IAuthUserService>(),
                                  ),
                                  child: BlocBuilder<
                                          UserPreferenceSubmitBtnController,
                                          UserPreferenceSubmitBtnState>(
                                      builder: (context,
                                          userPreferenceSubmitBtnState) {
                                    return BlocListener<
                                        UserPreferenceSubmitBtnController,
                                        UserPreferenceSubmitBtnState>(
                                      listener: (context, state) {
                                        if (state
                                            is UserPreferenceSubmitBtnSuccess) {
                                          context.go('/home');
                                        }
                                      },
                                      child: MainBtn(
                                        isLoading: userPreferenceSubmitBtnState
                                            is UserPreferenceSubmitBtnLoading,
                                        text: _currentPageIndex ==
                                                questions.length - 1
                                            ? appTexts.finish
                                            : appTexts.next,
                                        showRightIcon: _currentPageIndex == 0,
                                        onPressed: () async {
                                          final userPreferenceSubmitBtnController =
                                              context.read<
                                                  UserPreferenceSubmitBtnController>();
                                          if (_currentPageIndex ==
                                              questions.length - 1) {
                                            final enableNotif =
                                                await showNotificationDialog();
                                            log('enableNotif: $enableNotif');

                                            userPreferenceSubmitBtnController
                                                .submit(questions);
                                            return;
                                          }

                                          _nextPage();
                                        },
                                      ),
                                    );
                                  }),
                                ),
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

  @override
  bool get wantKeepAlive => true;
}
