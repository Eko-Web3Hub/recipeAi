import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/analytics/analytics_event.dart';
import 'package:recipe_ai/analytics/analytics_repository.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/home/presentation/translated_text.dart';
import 'package:recipe_ai/onboarding/presentation/onboarding_view_controller.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/user_preferences/presentation/components/onboarding_primary_button.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

/// First screen of the app: the brand, the promise and the two ways in.
/// Replaces the former 3 slides carousel and the "Se connecter / Créer un
/// compte" screen.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      di<IAnalyticsRepository>().logEvent(OnboardingStartedEvent());
    });
  }

  Future<void> _leaveTo(String path) async {
    // Marks the onboarding as seen so the splash routes returning users
    // straight here instead of replaying it.
    await context.read<OnboardingController>().completeOnboarding();
    if (!mounted) return;
    context.go(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: recipeLoaderCreamColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: SvgPicture.asset(
                    'assets/images/logo_eateasy_mono.svg',
                    width: 150,
                    colorFilter: const ColorFilter.mode(
                      recipeLoaderGreenColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 26, 28, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Eat'Easy",
                    style: TextStyle(
                      fontFamily: robotoSlabFontFamily,
                      fontWeight: FontWeight.w600,
                      fontSize: 34,
                      height: 1.05,
                      color: recipeLoaderGreenColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: TranslatedText(
                      textSelector: (lang) => lang.welcomeTagline,
                      style: TextStyle(
                        fontFamily: robotoFontFamily,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        height: 1.55,
                        color: recipeLoaderInkColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  Builder(
                    builder: (context) {
                      final appTexts =
                          di<TranslationController>().currentLanguage;

                      return OnboardingPrimaryButton(
                        label: appTexts.welcomeStartCta,
                        background: recipeLoaderGreenColor,
                        foreground: Colors.white,
                        onPressed: () => _leaveTo('/onboarding/register'),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _leaveTo('/onboarding/start/login'),
                      child: TranslatedText(
                        textSelector: (lang) => lang.welcomeAlreadyHaveAccount,
                        style: TextStyle(
                          fontFamily: robotoFontFamily,
                          fontWeight: FontWeight.w500,
                          fontSize: 12.5,
                          color: recipeLoaderInkColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
