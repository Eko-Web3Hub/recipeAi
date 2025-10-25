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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: questions
            .map<Widget>(
              (question) => Padding(
                padding: const EdgeInsets.only(bottom: 35.0),
                child: UserPreferenceQuestionWidget(
                  question: question,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
