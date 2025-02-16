import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/auth/presentation/components/main_btn.dart';
import 'package:recipe_ai/onboarding/domain/model/onboarding_model.dart';
import 'package:recipe_ai/onboarding/onboarding_first_section_widget.dart';
import 'package:recipe_ai/onboarding/personalized_preference_widget.dart';
import 'package:recipe_ai/onboarding/smart_receipe_generation_widget.dart';
import 'package:recipe_ai/utils/app_text.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

const _onBoardingFr = [
  OnboardingModel(
    title: appTexts.onboardingTitle1,
    child: OnboardingFirstSectionWidget(),
    description: appTexts.onboardingDesc1,
    horizontalPadding: 30,
    paddingBetweenTitleAndChild: 40,
  ),
  OnboardingModel(
    title: appTexts.onboardingTitle2,
    child: SmartReceipeGenerationWidget(),
    description: appTexts.onboardingDesc2,
    paddingBetweenTitleAndChild: 70,
  ),
  OnboardingModel(
    title: appTexts.onboardingTitle3,
    textColor: Colors.white,
    child: PersonalizedPreferenceWidget(),
  ),
];

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final controller = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Visibility(
            visible: _currentIndex == _onBoardingFr.length - 1,
            child: Image.asset(
              'assets/images/onboardingThreebackgroundImage.jpeg',
              fit: BoxFit.cover,
              height: double.infinity,
            ),
          ),
          Column(
            children: [
              const Gap(60),
              Expanded(
                child: PageView.builder(
                  controller: controller,
                  itemCount: _onBoardingFr.length,
                  clipBehavior: Clip.none,
                  onPageChanged: (value) {
                    setState(() {
                      _currentIndex = value;
                    });
                  },
                  itemBuilder: (context, index) {
                    final content = _onBoardingFr[index];
                    final widthScreen = MediaQuery.of(context).size.width;

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Visibility(
                          visible: index == 1,
                          child: Positioned(
                            left: (widthScreen / 2) + 34,
                            bottom: -30,
                            child: Stack(
                              children: [
                                SizedBox(
                                  width: 200,
                                  height: 200,
                                  child: Image.asset(
                                    'assets/images/receiptImage.png',
                                  ),
                                ),
                                Positioned(
                                  top: 10,
                                  left: 30,
                                  child: Image.asset(
                                    'assets/images/heartImage.png',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Center(
                              child: _OnboardingTitle(
                                content.title,
                                content.textColor,
                              ),
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
                  dotColor: _currentIndex == _onBoardingFr.length - 1
                      ? Colors.white
                      : const Color(0xFFD9D9D9),
                ),
              ),
              const Gap(20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 80),
                child: MainBtn(
                  text: appTexts.next,
                  onPressed: () {
                    if (controller.page == _onBoardingFr.length - 1) {
                      context.go(
                        '/login',
                      );
                    } else {
                      controller.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.ease,
                      );
                    }
                  },
                ),
              ),
              const Gap(13),
              InkWell(
                onTap: () => context.go(
                  '/login',
                ),
                child: Text(
                  appTexts.skip,
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
    required this.dotColor,
  });

  final PageController controller;
  final int count;
  final Color dotColor;

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
        dotColor: dotColor,
        activeDotColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
