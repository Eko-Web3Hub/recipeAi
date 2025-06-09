import 'package:flutter/material.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/l10n/app_localizations.dart';

class TranslatedText extends StatelessWidget {
  final String Function(AppLocalizations language) textSelector;
  final TextStyle? style;
  final TextAlign? textAlign;

  const TranslatedText({
    super.key,
    required this.textSelector,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: di<TranslationController>(),
        builder: (context, _) {
          return Text(
            textSelector(di<TranslationController>().currentLanguage),
            style: style,
            textAlign: textAlign,
          );
        });
  }
}
