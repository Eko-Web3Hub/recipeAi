import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:recipe_ai/auth/presentation/components/main_btn.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/home/presentation/profile_screen.dart';
import 'package:recipe_ai/nav/splash_screen.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/functions.dart';
import 'package:recipe_ai/utils/remote_config_data_source.dart';

class _ParsedVersion {
  const _ParsedVersion({
    required this.major,
    required this.minor,
    required this.patch,
  });

  factory _ParsedVersion.fromVersionString(String version) {
    final versionSplit = version.split('.');
    return _ParsedVersion(
      major: int.parse(versionSplit[0]),
      minor: int.parse(versionSplit[1]),
      patch: int.parse(versionSplit[2]),
    );
  }

  final int major;
  final int minor;
  final int patch;
}

class AppUpdatePopup extends StatelessWidget {
  const AppUpdatePopup({super.key});

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return DialogLayout(
      child: Column(
        children: [
          PopupTitle(
            title: appTexts.updateAvailable,
          ),
          const Gap(10),
          Text(
            appTexts.updateAvailableDescription,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const Gap(30),
          MainBtn(
            text: 'OK',
            onPressed: () => _redirectToStore().then((value) {
              Navigator.pop(context);
            }),
          )
        ],
      ),
    );
  }
}

Future<void> showAppUpdatePopup(BuildContext context) async {
  final packageInfo = await PackageInfo.fromPlatform();
  final pertinentVersionKey = Platform.isAndroid
      ? kAndroidRemoteConfigVersionKey
      : kiOSRemoteConfigVersionKey;
  final currentVersion = packageInfo.version;

  final shouldSuggestUpdate = _shouldSuggestUpdate(
    currentVersion: currentVersion,
    pertinentVersionKey: pertinentVersionKey,
  );
  if (!shouldSuggestUpdate) {
    return;
  }

  showDialog(
    context: context,
    builder: (context) => const AppUpdatePopup(),
  );
}

bool hasToInstallNewVersion({
  required String currentVersion,
  required String lastAvailableUpdate,
}) {
  final parsedCurrent = _ParsedVersion.fromVersionString(currentVersion);
  final parsedUpdate = _ParsedVersion.fromVersionString(lastAvailableUpdate);

  if (parsedCurrent.major < parsedUpdate.major) {
    return true;
  } else if (parsedCurrent.major == parsedUpdate.major &&
      parsedCurrent.minor < parsedUpdate.minor) {
    return true;
  } else if (parsedCurrent.major == parsedUpdate.major &&
      parsedCurrent.minor == parsedUpdate.minor &&
      parsedCurrent.patch < parsedUpdate.patch) {
    return true;
  }

  return false;
}

bool _shouldSuggestUpdate({
  required String currentVersion,
  required String pertinentVersionKey,
}) {
  final latestDeployedVersionOnStore =
      di<RemoteConfigDataSource>().getString(pertinentVersionKey);
  if (latestDeployedVersionOnStore.isEmpty) {
    return false;
  }

  final shouldSuggestUpdate = hasToInstallNewVersion(
    currentVersion: currentVersion,
    lastAvailableUpdate: latestDeployedVersionOnStore,
  );

  return shouldSuggestUpdate;
}

Future<void> _redirectToStore() async {
  final url = Platform.isIOS
      ? 'https://apps.apple.com/fr/app/eateasy/id6739941450'
      : 'https://play.google.com/store/apps/details?id=com.receipeapi.app';
  await launchUrlFunc(url);
}
