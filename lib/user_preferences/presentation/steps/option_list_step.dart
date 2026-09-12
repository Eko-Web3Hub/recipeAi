import 'package:flutter/material.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/user_preferences/domain/model/onboarding_answers.dart';
import 'package:recipe_ai/user_preferences/presentation/components/onboarding_option_tile.dart';
import 'package:recipe_ai/user_preferences/presentation/onboarding_steps.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

/// Options of a step, plus the free text field when the step has one
/// ("Autre" on the chronic disease step).
class OptionListStep extends StatefulWidget {
  const OptionListStep({
    super.key,
    required this.step,
    required this.answers,
    required this.onToggle,
    required this.onOtherChanged,
  });

  final OnboardingStep step;
  final OnboardingAnswers answers;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onOtherChanged;

  @override
  State<OptionListStep> createState() => _OptionListStepState();
}

class _OptionListStepState extends State<OptionListStep> {
  TextEditingController? _otherController;

  @override
  void initState() {
    super.initState();
    if (widget.step.hasOtherField) {
      _otherController = TextEditingController(
        text: widget.answers.chronicDiseaseOther,
      );
    }
  }

  @override
  void dispose() {
    _otherController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;
    final step = widget.step;
    // The single choice step of the mockup carries no checkbox: the selected
    // border and the green icon tile are the only markers.
    final showCheckbox = step.selectionMode == OptionSelectionMode.multiple;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final option in step.options) ...[
          if (option != step.options.first) const SizedBox(height: 10),
          OnboardingOptionTile(
            option: option,
            style: step.tileStyle,
            selected: widget.answers.isSelected(step.key, option.key),
            showCheckbox: showCheckbox,
            onTap: () => widget.onToggle(option.key),
          ),
        ],
        if (_otherController case final controller?) ...[
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            onChanged: widget.onOtherChanged,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(
              fontFamily: robotoFontFamily,
              fontWeight: FontWeight.w500,
              fontSize: 13.5,
              color: recipeLoaderInkColor,
            ),
            decoration: InputDecoration(
              hintText: appTexts.chronicOtherHint,
              hintStyle: const TextStyle(
                fontFamily: robotoFontFamily,
                fontWeight: FontWeight.w400,
                fontSize: 13.5,
                color: onboardingSubtleTextColor,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              enabledBorder: _border(onboardingOptionBorderColor, 1),
              focusedBorder: _border(recipeLoaderGreenColor, 1.5),
              border: _border(onboardingOptionBorderColor, 1),
            ),
          ),
        ],
      ],
    );
  }

  OutlineInputBorder _border(Color color, double width) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: color, width: width),
  );
}
