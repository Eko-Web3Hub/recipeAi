import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/utils/colors.dart';

import '../../../utils/constant.dart';

InputBorder _inputBorder = OutlineInputBorder(
  borderSide: const BorderSide(
    width: 1,
    color: greenPrimary80Color,
  ),
  borderRadius: BorderRadius.circular(
    10,
  ),
);

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
    required this.hintText,
    required this.controller,
    required this.validator,
    this.onChange,
    this.inputType = InputType.text,
    this.keyboardType,
    this.suffixIcon,
    this.initialValue,
  });

  final String hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Function(String)? onChange;
  final InputType inputType;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? initialValue;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.inputType == InputType.password;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextFormField(
        initialValue: widget.initialValue,
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        controller: widget.controller,
        cursorColor: Theme.of(context).primaryColor,
        onChanged: widget.onChange,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: widget.hintText,
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
          enabledBorder: _inputBorder.copyWith(borderSide: BorderSide.none),
          focusedBorder: _inputBorder,
          suffixIcon: widget.inputType == InputType.password
              ? IconButton(
                  icon: Icon(
                    _obscureText
                        ? FontAwesomeIcons.eyeSlash
                        : FontAwesomeIcons.eye,
                    color: const Color(0xffD9D9D9),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : widget.suffixIcon,
        ),
        obscureText: _obscureText,
      ),
    );
  }
}
