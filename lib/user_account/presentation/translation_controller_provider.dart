import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/user_account/domain/repositories/user_account_meta_data_repository.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TranslationControllerProvider extends StatelessWidget {
  const TranslationControllerProvider({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TranslationController(
        appLanguages,
        appLanguageFromString(
          AppLocalizations.of(context)!.localeName,
        ),
        di<IUserAccountMetaDataRepository>(),
        di<IAuthUserService>(),
      ),
      lazy: false,
      child: child,
    );
  }
}
