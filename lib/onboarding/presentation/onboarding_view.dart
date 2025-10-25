import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/analytics/analytics_event.dart';
import 'package:recipe_ai/analytics/analytics_repository.dart';
import 'package:recipe_ai/auth/presentation/components/main_btn.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/l10n/app_localizations.dart';
import 'package:recipe_ai/onboarding/domain/model/onboarding_model.dart';
import 'package:recipe_ai/onboarding/presentation/onboarding_first_section_widget.dart';
import 'package:recipe_ai/onboarding/presentation/onboarding_view_controller.dart';
import 'package:recipe_ai/onboarding/presentation/personalized_preference_widget.dart';
import 'package:recipe_ai/onboarding/presentation/smart_receipe_generation_widget.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

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
        description: appTexts.onboardingDesc3,
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

  final List<String> _onboardingAssets = [
    'onboarding_1.svg',
    'onboarding_2.svg',
    'onboarding_3.svg'
  ];

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

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return BlocListener<OnboardingController, OnboardingState?>(
      listener: (context, state) {
        if (state is OnboardingCompleted) {
          context.go('/onboarding/start');
        }
      },
      child: Builder(builder: (context) {
        return BlocBuilder<OnboardingController, OnboardingState?>(
          builder: (context, state) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: Stack(
                children: [
                  Visibility(
                    visible: _currentIndex < _onBoardingFr.length - 1,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: SvgPicture.asset(
                        'assets/images/shape_onboarding_1.svg',
                        width: 100.w,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _currentIndex == 0,
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 35),
                        child: SvgPicture.asset(
                          'assets/images/shape_onboarding_2.svg',
                          width: 100.w,
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _currentIndex == 1,
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 210),
                        child: SvgPicture.asset(
                          'assets/images/shape_onboarding_2_1.svg',
                          width: 100.w,
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _currentIndex == _onBoardingFr.length - 1,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SvgPicture.asset(
                        'assets/images/shape_onboarding_3.svg',
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _currentIndex == _onBoardingFr.length - 1,
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 240),
                        child: SvgPicture.asset(
                          'assets/images/shape_onboarding_3_1.svg',
                          width: 100.w,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50, right: 20),
                      child: TextButton(
                          onPressed: () {
                            context
                                .read<OnboardingController>()
                                .completeOnboarding();
                          },
                          child: Text(
                            appTexts.skip,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                color: orangePrimaryColor,
                                fontSize: 20),
                          )),
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
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: SvgPicture.asset(
                                      'assets/images/${_onboardingAssets[_currentIndex]}'),
                                )
                              ],
                            );
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _onBoardingFr.length,
                          (index) {
                            return _currentIndex != index
                                ? Opacity(
                                    opacity: 0.4,
                                    child: Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 4.0),
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                          color: orangePrimaryColor,
                                          shape: BoxShape.circle),
                                    ),
                                  )
                                : Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 4.0),
                                    width: 12.0,
                                    height: 12.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border:
                                          Border.all(color: orangePrimaryColor),
                                      color: Colors.white, // Points inactifs
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                            color: orangePrimaryColor,
                                            shape: BoxShape.circle),
                                      ),
                                    ),
                                  );
                          },
                        ),
                      ),

                      // _OnboardingDotPageIndicator(
                      //   controller: controller,
                      //   count: _onBoardingFr.length,
                      //   dotColor: Color(0xFFFFBA4D).withValues(alpha: 0.4),
                      // ),
                      const Gap(20),
                      _OnboardingTitle(
                        _onBoardingFr[_currentIndex].title,
                      ),
                      const Gap(5),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          _onBoardingFr[_currentIndex].description,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              height: 24 / 16,
                              color: const Color(0xFF97A2B0)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Gap(50),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: MainBtn(
                          backgroundColor: const Color(0xFFFFBA4D),
                          text: _currentIndex == _onBoardingFr.length - 1
                              ? appTexts.startCooking
                              : appTexts.next,
                          onPressed: () {
                            log(controller.page.toString());
                            if (controller.page == _onBoardingFr.length - 1) {
                              context
                                  .read<OnboardingController>()
                                  .completeOnboarding();
                            } else {
                              controller.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease,
                              );
                            }
                          },
                        ),
                      ),
                      // const Gap(13),
                      // InkWell(
                      //   onTap: () {
                      //     context
                      //         .read<OnboardingController>()
                      //         .completeOnboarding();
                      //   },
                      //   child: Text(
                      //     appTexts.skip,
                      //     style: GoogleFonts.poppins(
                      //       fontWeight: FontWeight.w600,
                      //       fontSize: 16,
                      //       height: 24 / 16,
                      //       color: Theme.of(context).primaryColor,
                      //     ),
                      //   ),
                      // ),
                      const Gap(40),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}

class _OnboardingTitle extends StatelessWidget {
  const _OnboardingTitle(
    this.title,
  );

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        title,
        style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 28,
            color: const Color(0xFF030319)),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// class _OnboardingDotPageIndicator extends StatelessWidget {
//   const _OnboardingDotPageIndicator({
//     required this.controller,
//     required this.count,
//     required this.dotColor,
//   });

//   final PageController controller;
//   final int count;
//   final Color dotColor;

//   @override
//   Widget build(BuildContext context) {
//     return SmoothPageIndicator(
//       controller: controller,
//       count: count,
//       onDotClicked: (i) async {
//         await controller.animateToPage(
//           i,
//           duration: const Duration(milliseconds: 500),
//           curve: Curves.ease,
//         );
//       },
//       effect: WormEffect(
//         spacing: 15.0,
//         radius: 8.0,
//         dotWidth: 10,
//         strokeWidth: 2,
//         dotHeight: 10,
//         dotColor: dotColor,
//         activeDotColor: Color(0xFFFFBA4D),
//       ),
//     );
//   }
// }
