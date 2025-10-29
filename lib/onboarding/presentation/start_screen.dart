import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/analytics/analytics_repository.dart';
import 'package:recipe_ai/auth/application/auth_service.dart';
import 'package:recipe_ai/auth/presentation/components/custom_snack_bar.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/onboarding/presentation/start_view_controller.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/colors.dart';

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
          backgroundColor: greenBrandColor,
          body: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: SvgPicture.asset('assets/images/intro_illustration.svg'),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: BlocBuilder<StartViewController, StartViewState?>(
                  builder: (context, state) {
                    return Padding(
                      padding: const EdgeInsets.only(
                          left: 30, right: 30, bottom: 50),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            appTexts.startDesc,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 28),
                          ),
                          const Gap(25),
                          MaterialButton(
                            height: 50,
                            elevation: 0,
                            minWidth: double.infinity,
                            color: orangePrimaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            onPressed: () {
                              context.push('/onboarding/start/login');
                            },
                            child: Text(
                              appTexts.signIn,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.white),
                            ),
                          ),
                          const Gap(10),
                          TextButton(
                              onPressed: () {
                                context.push('/onboarding/register');
                              },
                              child: Text(
                                appTexts.createAnAccount,
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16),
                              )),
                          const Gap(15),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
