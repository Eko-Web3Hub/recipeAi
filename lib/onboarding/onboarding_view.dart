import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/auth/presentation/components/main_btn.dart';
import 'package:recipe_ai/onboarding/domain/model/onboarding_model.dart';
import 'package:recipe_ai/onboarding/onboarding_first_section_widget.dart';
import 'package:recipe_ai/onboarding/smart_receipe_generation_widget.dart';
import 'package:recipe_ai/utils/app_text.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

const _onBoardingFr = [
  OnboardingModel(
    title: AppText.onboardingTitle1,
    child: OnboardingFirstSectionWidget(),
    description: AppText.onboardingDesc1,
    horizontalPadding: 30,
    paddingBetweenTitleAndChild: 40,
  ),
  OnboardingModel(
    title: AppText.onboardingTitle2,
    child: SmartReceipeGenerationWidget(),
    description: AppText.onboardingDesc2,
  ),
  OnboardingModel(
    title: AppText.onboardingTitle3,
    child: SizedBox.shrink(),
  ),
];

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Gap(60),
          Expanded(
            child: PageView.builder(
              controller: controller,
              itemCount: _onBoardingFr.length,
              clipBehavior: Clip.hardEdge,
              itemBuilder: (context, index) {
                final content = _onBoardingFr[index];

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _OnboardingTitle(
                      content.title,
                      content.textColor,
                    ),
                    const Gap(10),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: content.horizontalPadding,
                      ),
                      child: content.child,
                    ),
                    Gap(content.paddingBetweenTitleAndChild),
                    if (content.description != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 52,
                        ),
                        child: Text(
                          content.description!,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            height: 24 / 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _OnboardingDotPageIndicator(
              controller: controller,
              count: _onBoardingFr.length,
            ),
          ),
          const Gap(20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80),
            child: MainBtn(
              text: AppText.next,
              onPressed: () {},
            ),
          ),
          const Gap(13),
          InkWell(
            onTap: () => context.go(
              '/login',
            ),
            child: Text(
              AppText.skip,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                height: 24 / 16,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const Gap(13),
        ],
      ),
    );
  }
}

class _OnboardingTitle extends StatelessWidget {
  const _OnboardingTitle(
    this.title,
    this.textColor,
  );

  final String title;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: textColor == null
          ? Theme.of(context).textTheme.displayLarge
          : Theme.of(context).textTheme.displayLarge!.copyWith(
                color: textColor,
              ),
    );
  }
}

class _OnboardingDotPageIndicator extends StatelessWidget {
  const _OnboardingDotPageIndicator({
    required this.controller,
    required this.count,
  });

  final PageController controller;
  final int count;

  @override
  Widget build(BuildContext context) {
    return SmoothPageIndicator(
      controller: controller,
      count: count,
      onDotClicked: (i) async {
        await controller.animateToPage(
          i,
          duration: const Duration(milliseconds: 500),
          curve: Curves.ease,
        );
      },
      effect: WormEffect(
        spacing: 15.0,
        radius: 8.0,
        dotWidth: 10,
        dotHeight: 10,
        dotColor: const Color(0xFFD9D9D9),
        activeDotColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
