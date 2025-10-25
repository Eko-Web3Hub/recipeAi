import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/analytics/analytics_event.dart';
import 'package:recipe_ai/analytics/analytics_repository.dart';
import 'package:recipe_ai/auth/application/auth_service.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/presentation/components/custom_snack_bar.dart';
import 'package:recipe_ai/auth/presentation/components/main_btn.dart';
import 'package:recipe_ai/auth/presentation/components/outlined_form_field_with_label.dart';
import 'package:recipe_ai/auth/presentation/login_view_controller.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/home/presentation/translated_text.dart';
import 'package:recipe_ai/user_preferences/domain/repositories/user_preference_repository.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/functions.dart';
import 'package:recipe_ai/utils/styles.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../user_account/presentation/translation_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    di<IAnalyticsRepository>().logEvent(
      LoginStartEvent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return ListenableBuilder(
        listenable: di<TranslationController>(),
        builder: (context, _) {
          return BlocProvider(
            create: (context) => LoginViewController(
              di<IAuthService>(),
              di<IAnalyticsRepository>(),
              di<IUserPreferenceRepository>(),
              di<IAuthUserService>(),
            ),
            child: BlocListener<LoginViewController, LoginViewState>(
              listener: (context, state) {
                if (state is LoginViewSuccess) {
                  context.go('/home');
                } else if(state is EmptyUserPrefs) {
                  context.go('/user-preferences');
                } else if (state is LoginViewError) {
                  showSnackBar(
                    context,
                    state.message ?? appTexts.somethingWentWrong,
                    isError: true,
                  );
                }
              },
              child: Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  title: Text(
                    appTexts.signIn,
                    style: appBarTextStyle,
                  ),
                  leading: BackButton(),
                ),
                body: SafeArea(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: horizontalScreenPadding,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Gap(30),

                                OutlinedFormFieldWithLabel(
                                  label: appTexts.email,
                                  hintText: appTexts.enterEmail,
                                  prefixIcon: SvgPicture.asset(
                                    'assets/icon/message.svg',
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.cover,
                                  ),
                                  controller: _emailController,
                                  validator: (value) =>
                                      nonEmptyStringValidator(value, appTexts),
                                ),
                                const Gap(30.0),
                                OutlinedFormFieldWithLabel(
                                  label: appTexts.password,
                                  hintText: appTexts.enterPassword,
                                  controller: _passwordController,
                                  inputType: InputType.password,
                                  prefixIcon:
                                      SvgPicture.asset('assets/icon/lock.svg'),
                                  validator: (value) =>
                                      nonEmptyStringValidator(value, appTexts),
                                ),
                                const Gap(25.0),
                                BlocBuilder<LoginViewController,
                                        LoginViewState>(
                                    builder: (context, loginControllerState) {
                                  return MainBtn(
                                    text: appTexts.signIn,
                                    backgroundColor: orangePrimaryColor,
                                    showRightIcon: false,
                                    isLoading: loginControllerState
                                        is LoginViewLoading,
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        context
                                            .read<LoginViewController>()
                                            .login(
                                              email: _emailController.text,
                                              password:
                                                  _passwordController.text,
                                            );
                                      }
                                    },
                                  );
                                }),
                                const Gap(10),
                                Center(
                                  child: TextButton(
                                    onPressed: () =>
                                        context.go('/login/reset-password'),
                                    child: Text(
                                      appTexts.forgotPassword,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        height: 16.5 / 11,
                                        color: newNeutralBlackColor,
                                      ),
                                    ),
                                  ),
                                ),
                                const Gap(20.0),
                                // Center(
                                //   child: AuthBottomAction(
                                //     firstText: appTexts.dontHaveAnAccount,
                                //     secondText: ' ${appTexts.signUp}',
                                //     onPressed: () {
                                //       context.push('/register');
                                //     },
                                //   ),
                                // ),
                                const Gap(25.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Or continue with',
                                style: GoogleFonts.poppins(
                                    color: neutralGrey2Color, fontSize: 14),
                              ),
                              const Gap(18),
                              Builder(builder: (context) {
                                return MaterialButton(
                                  elevation: 0,
                                  minWidth: 100.w,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  onPressed: () {
                                    context
                                        .read<LoginViewController>()
                                        .googleSignIn();
                                  },
                                  height: 54,
                                  color: const Color(0xFFF06155),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icon/google_btn.svg',
                                        colorFilter: ColorFilter.mode(
                                            Colors.white, BlendMode.srcATop),
                                      ),
                                      const Gap(8),
                                      Text(
                                        appTexts.continueWithGoogle,
                                        style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              const Gap(16),
                              if (Platform.isIOS) ...[
                                SignInWithAppleBuilder(
                                  builder: (context) {
                                    return MaterialButton(
                                      elevation: 0,
                                      color: Colors.black,
                                      minWidth: 100.w,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      onPressed: () {
                                        context
                                            .read<LoginViewController>()
                                            .appleSignIn();
                                      },
                                      height: 54,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/icon/apple.svg',
                                            colorFilter: ColorFilter.mode(
                                                Colors.white,
                                                BlendMode.srcATop),
                                          ),
                                          const Gap(10),
                                          Text(
                                            appTexts.continueWithApple,
                                            style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const Gap(16),
                              ]
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}

class _HeadTitle extends StatelessWidget {
  const _HeadTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TranslatedText(
          textSelector: (lang) => lang.hello,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 30,
            height: 45 / 30,
          ),
        ),
        TranslatedText(
          textSelector: (lang) => lang.welcomeBack,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w400,
            fontSize: 20,
            height: 30 / 20,
          ),
        ),
      ],
    );
  }
}
