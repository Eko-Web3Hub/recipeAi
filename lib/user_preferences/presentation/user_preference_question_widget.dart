import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/auth/presentation/register/register_view.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference_question.dart';

class UserPreferenceQuestionWidget extends StatelessWidget {
  const UserPreferenceQuestionWidget({
    super.key,
    required this.question,
  });

  final UserPreferenceQuestion question;

  Widget _questionBuilder() {
    if (question.type == UserPreferenceQuestionType.multipleChoice) {
      final multipleChoiceQuestion =
          question as UserPreferenceQuestionMultipleChoice;

      return _MultipleChoiceQuestion(
        options: multipleChoiceQuestion.options,
      );
    } else {
      throw UnimplementedError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        HeadTitle(
          title: question.title,
          subTitle: question.description,
        ),
        const Gap(23),
        Padding(
          padding: const EdgeInsets.only(left: 1.0),
          child: _questionBuilder(),
        ),
      ],
    );
  }
}

class _MultipleChoiceQuestion extends StatelessWidget {
  const _MultipleChoiceQuestion({
    required this.options,
  });

  final List<String> options;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: options
          .map(
            (option) => Padding(
              padding: const EdgeInsets.only(
                bottom: 15.0,
              ),
              child: _CheckBoxOption(
                option: option,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _CheckBoxOption extends StatelessWidget {
  const _CheckBoxOption({
    required this.option,
  });

  final String option;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _CustomCheckBox(),
        const Gap(22),
        Text(
          option,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w400,
            fontSize: 16,
            height: 24 / 16,
            color: const Color(0xff1E1E1E),
          ),
        ),
      ],
    );
  }
}

class _CustomCheckBox extends StatefulWidget {
  const _CustomCheckBox();

  @override
  State<_CustomCheckBox> createState() => _CustomCheckBoxState();
}

class _CustomCheckBoxState extends State<_CustomCheckBox> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(
        () => isSelected = !isSelected,
      ),
      child: Container(
        width: 20.0,
        height: 20.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.black,
            width: 2.0,
          ),
          color:
              isSelected ? Theme.of(context).primaryColor : Colors.transparent,
        ),
        child: Icon(
          Icons.check,
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
