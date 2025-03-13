import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/analytics/analytics_event.dart';
import 'package:recipe_ai/analytics/analytics_repository.dart';
import 'package:recipe_ai/auth/presentation/components/main_btn.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/onboarding/domain/model/onboarding_model.dart';
import 'package:recipe_ai/onboarding/onboarding_first_section_widget.dart';
import 'package:recipe_ai/onboarding/personalized_preference_widget.dart';
import 'package:recipe_ai/onboarding/smart_receipe_generation_widget.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

List<OnboardingModel> _buildOnboarding(AppLocalizations appTexts) => [
      OnboardingModel(
        title: appTexts.onboardingTitle1,
        child: const OnboardingFirstSectionWidget(),
        description: appTexts.onboardingDesc1,
        horizontalPadding: 30,
        paddingBetweenTitleAndChild: 30,
      ),
      OnboardingModel(
        title: appTexts.onboardingTitle2,
        child: const SmartReceipeGenerationWidget(),
        description: appTexts.onboardingDesc2,
        paddingBetweenTitleAndChild: 60,
      ),
      OnboardingModel(
        title: appTexts.onboardingTitle3,
        textColor: Colors.white,
        child: const PersonalizedPreferenceWidget(),
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

  final List<OnboardingModel> _onBoardingFr =
      _buildOnboarding(di<TranslationController>().currentLanguage);

  @override
  void initState() {
    super.initState();

    di<IAnalyticsRepository>().logEvent(
      OnboardingStartedEvent(),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _logOnboardingCompleted() {
    di<IAnalyticsRepository>().logEvent(
      OnboardingCompletedEvent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

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
              const Gap(80),
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
                            left: (widthScreen / 2) * 1.5,
                            right: 0,
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
                                  left: 5,
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
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: _OnboardingTitle(
                                  content.title,
                                  content.textColor,
                                ),
                              ),
                            ),
                            const Gap(5),
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
                                  horizontal: 30,
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
                      _logOnboardingCompleted();
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
                onTap: () {
                  _logOnboardingCompleted();
                  context.go(
                    '/login',
                  );
                },
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
              const Gap(40),
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
      textAlign: TextAlign.center,
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
