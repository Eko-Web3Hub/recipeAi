import 'package:flutter/material.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

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
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
            height: 16.5 / 11,
            color: Colors.black,
            fontFamily: poppinsFontFamily,
          ),
          children: [
            TextSpan(
              text: secondText,
              style: TextStyle(
                fontFamily: poppinsFontFamily,
                color: orangeVariantColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
