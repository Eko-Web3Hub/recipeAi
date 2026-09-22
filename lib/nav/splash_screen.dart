import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:recipe_ai/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/user_account/domain/repositories/user_account_meta_data_repository.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/remote_config_data_source.dart';

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
    // Same logo, size and background as the native launch screen, so the
    // hand-over from the native splash to Flutter does not show.
    return Scaffold(
      backgroundColor: recipeLoaderCreamColor,
      body: Center(
        child: SvgPicture.asset(
          'assets/images/logo_eateasy_mono.svg',
          width: 150,
          colorFilter: const ColorFilter.mode(
            recipeLoaderGreenColor,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

void _registerTranslaterController(BuildContext context) {
  di.registerSingleton<TranslationController>(
    TranslationController(
      appLanguages,
      appLanguageFromString(AppLocalizations.of(context)!.localeName),
      di<IUserAccountMetaDataRepository>(),
      di<IAuthUserService>(),
    ),
  );
}

const kAndroidRemoteConfigVersionKey = 'latestDeployedVersionOnGoogle';
const kiOSRemoteConfigVersionKey = 'latestDeployedVersionOnApple';

Future<void> _initRemoteConfig() async {
  final currentAppVersion = (await PackageInfo.fromPlatform()).version;

  final defaultValues = {
    'termsAndConditionsUrl': '',
    kAndroidRemoteConfigVersionKey: currentAppVersion,
    kiOSRemoteConfigVersionKey: currentAppVersion,
  };

  await di<RemoteConfigDataSource>().initializeFirebaseRemoteConfig(
    defaultValues,
  );
}
