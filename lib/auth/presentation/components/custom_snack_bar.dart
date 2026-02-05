import 'package:flutter/material.dart';
import 'package:recipe_ai/utils/constant.dart';

void showSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontFamily: poppinsFontFamily,
        ),
      ),
      backgroundColor: isError ? Colors.red : Colors.green,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
