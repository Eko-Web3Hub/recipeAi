import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/utils/app_version.dart';
import 'package:recipe_ai/utils/device_info.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the help and bug report form, pre-filled with the user, the device
/// and the app version.
Future<void> openFeedbackForm() async {
  final encodedUid = Uri.encodeComponent(
    di<IAuthUserService>().currentUser!.uid.value,
  );
  final device = await deviceInfo();
  final appVersion = await getAppVersion();

  final encodedDevice = Uri.encodeComponent(device);
  final encodedAppVersion = Uri.encodeComponent(appVersion);

  final url =
      'https://tally.so/r/nGblKQ?uid=$encodedUid&device=$encodedDevice&version=$encodedAppVersion';

  await launchUrl(Uri.parse(url));
}
