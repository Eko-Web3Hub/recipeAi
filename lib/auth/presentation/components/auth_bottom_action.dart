import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/utils/colors.dart';

class AuthBottomAction extends StatelessWidget {
  const AuthBottomAction({
    super.key,
    required this.firstText,
    required this.secondText,
    required this.onPressed,
  });

  final String firstText;
  final String secondText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: RichText(
        text: TextSpan(
          text: firstText,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 11,
            height: 16.5 / 11,
            color: Colors.black,
          ),
          children: [
            TextSpan(
              text: secondText,
              style: GoogleFonts.poppins(
                color: orangeVariantColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
