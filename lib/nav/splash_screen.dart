import 'package:flutter/material.dart';
import 'package:recipe_ai/di/container.dart';
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

Future<void> _initRemoteConfig() async {
  final defaultValues = {'termsAndConditionsUrl': ''};

  await di<RemoteConfigDataSource>()
      .initializeFirebaseRemoteConfig(defaultValues);
}
