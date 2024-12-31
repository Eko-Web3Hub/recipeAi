import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/auth/presentation/components/main_btn.dart';
import 'package:recipe_ai/utils/app_text.dart';
import 'package:recipe_ai/utils/styles.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const Gap(50),
            Image.asset('assets/images/logo.png'),
            const Gap(11),
            Text(
              AppText.startScreenDescription,
              style: normalSmallTextStyle.copyWith(
                color: Theme.of(context).primaryColor,
              ),
              textAlign: TextAlign.center,
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
                          text: AppText.startCooking,
                          onPressed: () => context.go('/login'),
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
