import 'package:package_info_plus/package_info_plus.dart';

class AppVersion {
  AppVersion({
    required this.version,
    required this.buildNumber,
  });

  factory AppVersion.fromPackageInfo(
    PackageInfo packageInfo,
  ) {
    return AppVersion(
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
    );
  }

  @override
  String toString() {
    return '$version+$buildNumber';
  }

  final String version;
  final String buildNumber;
}

Future<String> getAppVersion() async {
  final packageInfo = await PackageInfo.fromPlatform();
  final appVersion = AppVersion.fromPackageInfo(packageInfo);
  return appVersion.toString();
}
