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
              child: _CheckBoxOption(
                option: option,
                onChanged: (isSelected) {
                  print('Option: $option, isSelected: $isSelected');
                  question.answer(option);
                },
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
    required this.onChanged,
  });

  final String option;
  final Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CustomCheckBox(
          (isSelected) {
            onChanged(isSelected);
          },
        ),
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
  const _CustomCheckBox(
    this.onChanged,
  );

  final Function(bool) onChanged;

  @override
  State<_CustomCheckBox> createState() => _CustomCheckBoxState();
}

class _CustomCheckBoxState extends State<_CustomCheckBox> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          isSelected = !isSelected;
        });
        widget.onChanged(isSelected);
      },
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
          size: 15,
        ),
      ),
    );
  }
}
