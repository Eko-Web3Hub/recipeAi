import 'package:flutter/material.dart';
import 'package:recipe_ai/user_preferences/domain/model/onboarding_answers.dart';
import 'package:recipe_ai/user_preferences/domain/model/onboarding_step.dart';
import 'package:recipe_ai/user_preferences/presentation/onboarding_display.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

/// "Tes préférences diététiques": titled sections of chips, then the free text
/// field when the step has one ("aliments que tu n'aimes pas").
class ChipsStep extends StatefulWidget {
  const ChipsStep({
    super.key,
    required this.step,
    required this.answers,
    required this.onToggle,
    required this.onTextChanged,
  });

  final OnboardingStep step;
  final OnboardingAnswers answers;
  final ValueChanged<String> onToggle;

  /// `(preferenceKey, text)` of the free text field.
  final void Function(String preferenceKey, String text) onTextChanged;

  @override
  State<ChipsStep> createState() => _ChipsStepState();
}

class _ChipsStepState extends State<ChipsStep> {
  late final TextEditingController _textController = TextEditingController(
    text: switch (widget.step.otherField) {
      final field? => widget.answers.textOf(field.preferenceKey),
      null => '',
    },
  );

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.step;
    final otherField = step.otherField;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final section in step.sections) ...[
          _SectionLabel(section.title.text),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in section.options)
                _OptionChip(
                  label: option.label.text,
                  selected: widget.answers.isSelected(step.key, option.key),
                  onTap: () => widget.onToggle(option.key),
                ),
            ],
          ),
          const SizedBox(height: 22),
        ],
        if (otherField != null) ...[
          if (otherField.title case final title?) ...[
            _SectionLabel(title.text),
            const SizedBox(height: 10),
          ],
          TextField(
            controller: _textController,
            onChanged: (text) =>
                widget.onTextChanged(otherField.preferenceKey, text),
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(
              fontFamily: robotoFontFamily,
              fontWeight: FontWeight.w500,
              fontSize: 13.5,
              color: recipeLoaderInkColor,
            ),
            decoration: InputDecoration(
              hintText: otherField.hint.text,
              hintStyle: const TextStyle(
                fontFamily: robotoFontFamily,
                fontWeight: FontWeight.w400,
                fontSize: 13.5,
                color: onboardingSubtleTextColor,
              ),
              filled: true,
              fillColor: recipeLoaderInkColor.withValues(alpha: 0.05),
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontFamily: robotoFontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 10.5,
        letterSpacing: 0.6,
        color: onboardingSubtleTextColor,
      ),
    );
  }
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? recipeLoaderMintColor : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected
                ? recipeLoaderGreenColor
                : onboardingOptionBorderColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          selected ? '✓ $label' : label,
          style: TextStyle(
            fontFamily: robotoFontFamily,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
            color: selected
                ? recipeLoaderGreenColor
                : onboardingHelperTextColor,
          ),
        ),
      ),
    );
  }
}
