import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/utils/colors.dart';

import '../../../utils/constant.dart';

InputBorder _inputBorder = OutlineInputBorder(
  borderSide: const BorderSide(color: Color(0xFFE6EBF2), width: 1.5),
  borderRadius: BorderRadius.circular(
    16,
  ),
);

class OutlinedTextFormField extends StatefulWidget {
  const OutlinedTextFormField({
    super.key,
    required this.hintText,
    required this.controller,
    required this.validator,
    this.onChange,
    this.inputType = InputType.text,
    this.keyboardType,
    this.suffixIcon,
    this.initialValue,
    this.isReadOnly = false,
    this.prefixIcon,
  });

  final String hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Function(String)? onChange;
  final InputType inputType;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? initialValue;
  final bool isReadOnly;

  @override
  State<OutlinedTextFormField> createState() => _OutlinedTextFormFieldState();
}

class _OutlinedTextFormFieldState extends State<OutlinedTextFormField> {
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
        readOnly: widget.isReadOnly,
        initialValue: widget.initialValue,
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        controller: widget.controller,
        cursorColor: orangePrimaryColor,
        onChanged: widget.onChange,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: widget.hintText,
          hintStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            height: 16.5 / 11,
            color: const Color(0xff97A2B0),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          border: _inputBorder,
          enabledBorder: _inputBorder,
          focusedBorder: _inputBorder,
          prefixIcon: widget.prefixIcon != null
              ? Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: widget.prefixIcon,
                )
              : null,
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
