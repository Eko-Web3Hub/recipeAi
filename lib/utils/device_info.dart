import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

Future<String> deviceInfo() async {
  final deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    return '${androidInfo.brand} ${androidInfo.model}';
  }

  return (await deviceInfo.iosInfo).utsname.machine;
}
