import 'package:flutter/material.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/user_account/domain/repositories/user_account_meta_data_repository.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/remote_config_data_source.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initRemoteConfig();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _registerTranslaterController(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/logo.png',
        ),
      ),
    );
  }
}

void _registerTranslaterController(BuildContext context) {
  di.registerSingleton<TranslationController>(
    TranslationController(
      appLanguages,
      appLanguageFromString(
        AppLocalizations.of(context)!.localeName,
      ),
      di<IUserAccountMetaDataRepository>(),
      di<IAuthUserService>(),
    ),
  );
}

Future<void> _initRemoteConfig() async {
  final defaultValues = {'termsAndConditionsUrl': ''};

  await di<RemoteConfigDataSource>()
      .initializeFirebaseRemoteConfig(defaultValues);
}
