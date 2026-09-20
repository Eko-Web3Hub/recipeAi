import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/notification/application/fcm_token_service.dart';
import 'package:recipe_ai/notification/presentation/notification_user_controller.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

const _nextRoute = '/user-preferences';

/// Permission priming screen shown right after signing up: explains what the
/// notifications are for before the system prompt appears.
class NotificationPermissionScreen extends StatefulWidget {
  const NotificationPermissionScreen({super.key});

  @override
  State<NotificationPermissionScreen> createState() =>
      _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState
    extends State<NotificationPermissionScreen> {
  bool _isRequesting = false;

  /// Hides the content until we know the system prompt is still to be shown.
  bool _isCheckingPermission = true;

  @override
  void initState() {
    super.initState();
    _skipIfAlreadyAnswered();
  }

  Future<void> _skipIfAlreadyAnswered() async {
    var hasAnswered = false;
    try {
      hasAnswered = await di<FCMTokenService>().hasAnsweredPermission();
    } catch (_) {
      // Unknown: show the screen, the user can still skip it.
    }
    if (!mounted) return;
    if (hasAnswered) {
      context.go(_nextRoute);
    } else {
      setState(() => _isCheckingPermission = false);
    }
  }

  Future<void> _allow() async {
    final controller = context.read<NotificationUserController>();
    setState(() => _isRequesting = true);
    try {
      await controller.requestPermission(true);
    } finally {
      // The user moves on whatever the system answered: a denied permission
      // must not trap them on this screen.
      if (mounted) {
        setState(() => _isRequesting = false);
        context.go(_nextRoute);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    if (_isCheckingPermission) {
      return const Scaffold(backgroundColor: recipeLoaderGreenColor);
    }

    return Scaffold(
      backgroundColor: recipeLoaderGreenColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 26),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Text(
                appTexts.notificationPermissionTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: robotoSlabFontFamily,
                  fontWeight: FontWeight.w600,
                  fontSize: 34,
                  height: 1.05,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              const NotificationPreviewCard(),
              const SizedBox(height: 40),
              Text(
                appTexts.notificationPermissionWhy,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: robotoFontFamily,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                appTexts.notificationPermissionBody,
                textAlign: TextAlign.center,
                style: notificationPrimingBodyStyle,
              ),
              const SizedBox(height: 24),
              Text(
                appTexts.notificationPermissionBody2,
                textAlign: TextAlign.center,
                style: notificationPrimingBodyStyle,
              ),
              const Spacer(),
              _GhostButton(
                label: appTexts.onboardingContinue,
                isLoading: _isRequesting,
                onTap: _allow,
              ),
              const SizedBox(height: 14),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _isRequesting ? null : () => context.go(_nextRoute),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    appTexts.notificationPermissionLater,
                    style: TextStyle(
                      fontFamily: robotoFontFamily,
                      fontWeight: FontWeight.w500,
                      fontSize: 12.5,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final notificationPrimingBodyStyle = TextStyle(
  fontFamily: robotoFontFamily,
  fontWeight: FontWeight.w400,
  fontSize: 14,
  height: 1.55,
  color: Colors.white.withValues(alpha: 0.92),
);

/// Mock of the push notification the user is about to allow, also shown on
/// the profile notification settings.
class NotificationPreviewCard extends StatelessWidget {
  const NotificationPreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2E000000),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: recipeLoaderGreenColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.water_drop, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Eat'Easy",
                        style: TextStyle(
                          fontFamily: robotoFontFamily,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                          color: recipeLoaderInkColor,
                        ),
                      ),
                    ),
                    Text(
                      appTexts.notificationPreviewTime,
                      style: TextStyle(
                        fontFamily: robotoFontFamily,
                        fontWeight: FontWeight.w400,
                        fontSize: 10.5,
                        color: recipeLoaderInkColor.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  appTexts.notificationPreviewTitle,
                  style: const TextStyle(
                    fontFamily: robotoFontFamily,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                    color: recipeLoaderInkColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  appTexts.notificationPreviewBody,
                  style: TextStyle(
                    fontFamily: robotoFontFamily,
                    fontWeight: FontWeight.w400,
                    fontSize: 12.5,
                    height: 1.4,
                    color: recipeLoaderInkColor.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({
    required this.label,
    required this.onTap,
    required this.isLoading,
  });

  final String label;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(15);

    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        child: Container(
          height: 55,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(color: Colors.white, width: 1),
          ),
          alignment: Alignment.center,
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontFamily: robotoFontFamily,
                    fontWeight: FontWeight.w600,
                    fontSize: 19,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
