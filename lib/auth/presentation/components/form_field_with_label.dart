import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/auth/presentation/components/custom_text_form_field.dart';

class FormFieldWithLabel extends StatelessWidget {
  const FormFieldWithLabel({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
  });

  final String label;
  final String hintText;
  final TextEditingController? controller;

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
            fontSize: 14,
            height: 21 / 14,
            color: const Color(0xff121212),
          ),
        ),
        const Gap(5),
        CustomTextFormField(
          hintText: hintText,
          controller: controller,
        ),
      ],
    );
  }
}
