import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/auth/presentation/register/register_view.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference_question.dart';
import 'package:recipe_ai/utils/colors.dart';

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
        const Gap(25),
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
    return Wrap(
      spacing: 14,
      runSpacing: 16,
      direction: Axis.horizontal,
      children: question.options
          .map(
            (option) => CheckBoxOption(
              option: option.label,
              isSelected: question.isOptionSelected(option.key),
              onChanged: (isSelected) {
                question.answer(option.key);
              },
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
    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected = !isSelected;
        });
        widget.onChanged(isSelected);
      },
      child: Chip(
        elevation: 5,
        shadowColor: Color.fromRGBO(6, 51, 54, 0.1),
        side: isSelected
            ? BorderSide(color: greenPrimaryColor, width: 1.5)
            : BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.all(8),
        backgroundColor: isSelected ? Colors.white : neutralGrey4Color,
        avatar: isSelected
            ? Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                    color: greenPrimaryColor,
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                ),
              )
            : Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFC4C4C4),
                ),
              ),
        label: Text(
          widget.option,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
