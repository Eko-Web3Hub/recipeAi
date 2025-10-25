import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/auth/presentation/components/outlined_text_form_field.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

class OutlinedFormFieldWithLabel extends StatelessWidget {
  const OutlinedFormFieldWithLabel({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    required this.validator,
    this.inputType = InputType.text,
    this.keyboardType,
    this.onChange,
    this.initialValue,
    this.prefixIcon,
  });

  final String label;
  final String hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final InputType inputType;
  final TextInputType? keyboardType;
  final Function(String)? onChange;
  final String? initialValue;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w400,
            fontSize: 16,
            height: 21 / 14,
            color: neutralBlackColor,
          ),
        ),
        const Gap(5),
        OutlinedTextFormField(
          hintText: hintText,
          controller: controller,
          validator: validator,
          prefixIcon: prefixIcon,
          inputType: inputType,
          keyboardType: keyboardType,
          onChange: onChange,
          initialValue: initialValue,
        ),
      ],
    );
  }
}
