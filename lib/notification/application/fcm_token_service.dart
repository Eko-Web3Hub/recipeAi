import 'dart:async';

import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/utils/function_caller.dart';

/// A services to manage the fcm token of a user.

class FCMTokenService {
  /// Creates a [FCMTokenService].
  FCMTokenService(this._messaging, this._authService, this._functionsCaller) {
    _init();
  }

  FCMTokenService.inject(DiContainer di)
      : this(FirebaseMessaging.instance, di<IAuthUserService>(),
            di<FunctionsCaller>());

  final FirebaseMessaging _messaging;
  final IAuthUserService _authService;
  final FunctionsCaller _functionsCaller;

  StreamSubscription<AuthUser?>? _userSubscription;
  StreamSubscription<String?>? _fcmTokenSubscription;

  Future<bool> requestPermission() async {
    final tokensOk = await _waitForTokens();
    if (!tokensOk) {
      return false;
    }
    final settings = await _messaging.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  void _init() {
    _userSubscription = _authService.authStateChanges.listen(_onUserChanged);
  }

  void dispose() {
    _userSubscription?.cancel();
    _fcmTokenSubscription?.cancel();
  }

  Future<void> _onUserChanged(AuthUser? user, {bool triedAgain = false}) async {
    // Wait for the APNS token to be available
    // It is a known issue of Firebase Messaging
    final tokensOk = await _waitForTokens();
    if (!tokensOk) {
      return;
    }
    await _fcmTokenSubscription?.cancel();
    if (user == null) {
      return;
    }
    final currentToken = await _messaging.getToken();
    if (currentToken != null) {
      await _sendToken(user.uid.value, currentToken);
    }
    _fcmTokenSubscription = _messaging.onTokenRefresh.listen((token) {
      _sendToken(user.uid.value, token);
    });
  }

  Future<bool> _waitForTokens({bool triedAgain = false}) async {
    if (Platform.isAndroid) {
      return Future.value(true);
    }
    // Wait for the APNS token to be available only on iOS
    final tokens = await _messaging.getAPNSToken();
    if (tokens == null) {
      if (triedAgain) {
        return false;
      }
      // Try again
      await Future<void>.delayed(const Duration(seconds: 1));
      return _waitForTokens(triedAgain: true);
    }
    return true;
  }

  Future<void> _sendToken(String uid, String token) {
    return _functionsCaller.callFunction(
      'add_fcm_token',
      {
        'uid': uid,
        'value': token,
        'deviceType': Platform.isIOS ? 'iOS' : 'Android',
      },
    );
  }
}
