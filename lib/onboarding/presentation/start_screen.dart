import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/analytics/analytics_repository.dart';
import 'package:recipe_ai/auth/application/auth_service.dart';
import 'package:recipe_ai/auth/presentation/components/custom_snack_bar.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/onboarding/presentation/start_view_controller.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/styles.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return BlocProvider(
      create: (context) => StartViewController(
        di<IAuthService>(),
        di<IAnalyticsRepository>(),
      ),
      child: BlocListener<StartViewController, StartViewState?>(
        listener: (context, state) {
          if (state is StartViewSuccess) {
            context.go('/home');
          } else if (state is StartViewError) {
            showSnackBar(
              context,
              state.message ?? appTexts.somethingWentWrong,
              isError: true,
            );
          }
        },
        child: Scaffold(
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
                        child: BlocBuilder<StartViewController, StartViewState?>(
                          builder: (context, state) {
                            final controller =
                                context.read<StartViewController>();
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 30, right: 30, bottom: 50),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  MaterialButton(
                                    height: 50,
                                    minWidth: double.infinity,
                                    color: Theme.of(context).primaryColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    onPressed: () {
                                      context.go('/login');
                                    },
                                    child: Text(
                                      appTexts.letsCook,
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: Colors.white),
                                    ),
                                  ),
                                  const Gap(15),
                                  SignInWithAppleBuilder(
                                    builder: (context) {
                                      return MaterialButton(
                                        minWidth: double.infinity,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        onPressed: () {
                                          controller.appleSignIn();
                                        },
                                        height: 50,
                                        color: Colors.white,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SvgPicture.asset(
                                                'assets/icon/apple.svg'),
                                            const Spacer(
                                              flex: 2,
                                            ),
                                            Text(
                                              appTexts.continueWithApple,
                                              style:
                                                  normalSmallTextStyle.copyWith(
                                                color: Colors.black,
                                              ),
                                            ),
                                            const Spacer(
                                              flex: 3,
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  const Gap(15),
                                  MaterialButton(
                                    minWidth: double.infinity,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    onPressed: () {
                                      controller.googleSignIn();
                                    },
                                    height: 50,
                                    color: Colors.white,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SvgPicture.asset(
                                            'assets/icon/google_btn.svg'),
                                        const Spacer(
                                          flex: 2,
                                        ),
                                        Text(
                                          appTexts.continueWithGoogle,
                                          style: normalSmallTextStyle.copyWith(
                                            color: Colors.black,
                                          ),
                                        ),
                                        const Spacer(
                                          flex: 3,
                                        )
                                      ],
                                    ),
                                  ),
                                  const Gap(15),
                                  MaterialButton(
                                    minWidth: double.infinity,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    onPressed: () {
                                      context.go('/login');
                                    },
                                    height: 50,
                                    color: Colors.white,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.email_outlined),
                                        const Spacer(
                                          flex: 2,
                                        ),
                                        Text(
                                          appTexts.continueWithEmail,
                                          style: normalSmallTextStyle.copyWith(
                                            color: Colors.black,
                                          ),
                                        ),
                                        const Spacer(
                                          flex: 3,
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
