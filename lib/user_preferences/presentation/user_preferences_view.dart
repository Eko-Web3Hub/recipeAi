import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:recipe_ai/auth/presentation/components/main_btn.dart';
import 'package:recipe_ai/user_preferences/presentation/user_preference_question_list.dart';
import 'package:recipe_ai/utils/app_text.dart';
import 'package:recipe_ai/utils/constant.dart';

class UserPreferencesView extends StatelessWidget {
  const UserPreferencesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: horizontalScreenPadding,
        ),
        child: Column(
          children: [
            Expanded(
              child: UserPreferenceQuestionList(
                questions: [],
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
      ),
    );
  }
}
