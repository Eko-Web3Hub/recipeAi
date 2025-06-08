import 'dart:developer';
import 'package:url_launcher/url_launcher.dart';
import 'package:validators/validators.dart';
import 'package:recipe_ai/l10n/app_localizations.dart';

String? nonEmptyStringValidator(String? value, AppLocalizations appTexts) {
  if (value == null || value.isEmpty) {
    return appTexts.fieldCannotBeEmpty;
  }
  return null;
}

String? emailValidator(String? value, AppLocalizations appTexts) {
  if (value == null || value.isEmpty) {
    return appTexts.fieldCannotBeEmpty;
  }
  if (!isEmail(value)) {
    return appTexts.invalidEmail;
  }
  return null;
}

String? passwordValidator(String? value, AppLocalizations appTexts) {
  if (value == null || value.isEmpty) {
    return '';
  }
  if (value.length < 6) {
    return '';
  }

  if (!value.contains(RegExp(r'[0-9]'))) {
    return '';
  }

  if (!value.contains(RegExp(r'[A-Z]'))) {
    return '';
  }

  return null;
}

bool isPasswordValid(String value) {
  if (value.length < 6) {
    return false;
  }

  if (!value.contains(RegExp(r'[0-9]'))) {
    return false;
  }

  if (!value.contains(RegExp(r'[A-Z]'))) {
    return false;
  }

  return true;
}

String? confirmPasswordValidator(
    String? value, String password, AppLocalizations appTexts) {
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

String convertRecipeNameToFirestoreId(String recipeName) {
  return recipeName.replaceAll(' ', '_').toLowerCase();
}
