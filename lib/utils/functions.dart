import 'dart:developer';

import 'package:recipe_ai/utils/app_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:validators/validators.dart';

String? nonEmptyStringValidator(String? value) {
  if (value == null || value.isEmpty) {
    return appTexts.fieldCannotBeEmpty;
  }
  return null;
}

String? emailValidator(String? value) {
  if (value == null || value.isEmpty) {
    return appTexts.fieldCannotBeEmpty;
  }
  if (!isEmail(value)) {
    return appTexts.invalidEmail;
  }
  return null;
}

String? passwordValidator(String? value) {
  if (value == null || value.isEmpty) {
    return appTexts.fieldCannotBeEmpty;
  }
  if (value.length < 6) {
    return 'Password must be at least 6 characters';
  }

  if (!value.contains(RegExp(r'[0-9]'))) {
    return 'Password must contain at least one number';
  }

  if (!value.contains(RegExp(r'[A-Z]'))) {
    return 'Password must contain at least one  \n uppercase letter';
  }

  return null;
}

String? confirmPasswordValidator(String? value, String password) {
  if (value == null || value.isEmpty) {
    return appTexts.fieldCannotBeEmpty;
  }
  if (value != password) {
    return 'Password does not match';
  }
  return null;
}

String capitalizeFirtLetter(String s) {
  return s[0].toUpperCase() + s.substring(1);
}

Future<void> launchUrlFunc(String url) async {
  final uri = Uri.parse(url);

  try {
    await launchUrl(uri);
  } catch (e) {
    log(e.toString());
  }
}
