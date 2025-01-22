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
        question: multipleChoiceQuestion,
      );
    } else {
      throw UnimplementedError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
    required this.question,
  });

  final UserPreferenceQuestionMultipleChoice question;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: question.options
          .map(
            (option) => Padding(
              padding: const EdgeInsets.only(
                bottom: 15.0,
              ),
              child: CheckBoxOption(
                option: option,
                isSelected: question.isOptionSelected(option),
                onChanged: (isSelected) {
                  question.answer(option);
                },
              ),
            ),
          )
          .toList(),
    );
  }
}

class CheckBoxOption extends StatefulWidget {
  const CheckBoxOption({
    super.key,
    required this.option,
    this.isSelected = false,
    required this.onChanged,
  });

  final String option;
  final bool isSelected;
  final Function(bool) onChanged;

  @override
  State<CheckBoxOption> createState() => _CheckBoxOptionState();
}

class _CheckBoxOptionState extends State<CheckBoxOption> {
  bool isSelected = false;

  @override
  void initState() {
    super.initState();
    isSelected = widget.isSelected;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          isSelected = !isSelected;
        });
        widget.onChanged(isSelected);
      },
      child: Row(
        children: [
          _CustomCheckBox(
            isSelected: isSelected,
          ),
          const Gap(22),
          Expanded(
            child: Text(
              widget.option,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                fontSize: 16,
                height: 24 / 16,
                color: const Color(0xff1E1E1E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomCheckBox extends StatelessWidget {
  const _CustomCheckBox({
    this.isSelected = false,
  });

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20.0,
      height: 20.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? Colors.transparent : Colors.black,
          width: 2.0,
        ),
        color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
      ),
      child: Icon(
        Icons.check,
        color: isSelected ? Colors.white : Colors.black,
        size: 15,
      ),
    );
  }
}
