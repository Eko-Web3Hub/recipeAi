import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/constant.dart';

InputBorder _inputBorder = OutlineInputBorder(
  borderSide: const BorderSide(
    width: 1.5,
    color: Color(0xffD9D9D9),
  ),
  borderRadius: BorderRadius.circular(
    10,
  ),
);

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required this.hintText,
    required this.controller,
    required this.validator,
    this.inputType = InputType.text,
    this.keyboardType,
  });

  final String hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final InputType inputType;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextFormField(
        keyboardType: keyboardType,
        validator: validator,
        controller: controller,
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w400,
            fontSize: 11,
            height: 16.5 / 11,
            color: const Color(0xffD9D9D9),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          border: _inputBorder,
          enabledBorder: _inputBorder,
          focusedBorder: _inputBorder,
        ),
        obscureText: inputType == InputType.password,
      ),
    );
  }
}
