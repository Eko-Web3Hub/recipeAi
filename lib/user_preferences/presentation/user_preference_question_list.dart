import 'package:flutter/material.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference_question.dart';
import 'package:recipe_ai/user_preferences/presentation/user_preference_question_widget.dart';

class UserPreferenceQuestionList extends StatelessWidget {
  const UserPreferenceQuestionList({
    super.key,
    required this.questions,
    required this.controller,
    required this.onPageChanged,
  });

  final List<UserPreferenceQuestion> questions;
  final PageController? controller;
  final Function(int)? onPageChanged;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemCount: questions.length,
      controller: controller,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final question = questions[index];
        return UserPreferenceQuestionWidget(
          question: question,
        );
      },
      onPageChanged: onPageChanged,
    );
  }
}
