import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/auth/presentation/components/main_btn.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/styles.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const Gap(50),
            SizedBox(
              height: 150,
              child: Image.asset(logoPath),
            ),
            const Gap(11),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Text(
                appTexts.startScreenDescription,
                style: normalSmallTextStyle.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Gap(24.0),
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/images/startScreenImage.png',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 66,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 50),
                        child: MainBtn(
                          leftArrowPadding: 10,
                          text: appTexts.startCooking,
                          onPressed: () => context.go('/onboarding/slider'),
                          showRightIcon: true,
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
