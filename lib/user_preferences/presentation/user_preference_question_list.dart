import 'package:flutter/material.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference_question.dart';
import 'package:recipe_ai/user_preferences/presentation/user_preference_question_widget.dart';

class UserPreferenceQuestionList extends StatelessWidget {
  const UserPreferenceQuestionList({
    super.key,
    required this.questions,
  });

  final List<UserPreferenceQuestion> questions;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final question = questions[index];
        return UserPreferenceQuestionWidget(
          question: question,
        );
      },
    );
  }
}
