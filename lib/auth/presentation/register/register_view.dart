import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/analytics/analytics_event.dart';
import 'package:recipe_ai/analytics/analytics_repository.dart';
import 'package:recipe_ai/auth/application/register_usecase.dart';
import 'package:recipe_ai/auth/presentation/components/auth_bottom_action.dart';
import 'package:recipe_ai/auth/presentation/components/custom_snack_bar.dart';
import 'package:recipe_ai/auth/presentation/components/form_field_with_label.dart';
import 'package:recipe_ai/auth/presentation/components/main_btn.dart';
import 'package:recipe_ai/auth/presentation/register/register_controller.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/functions.dart';
import 'package:recipe_ai/utils/remote_config_data_source.dart';

import '../../../user_account/presentation/translation_controller.dart';

int _passwordMinLength = 6;

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String password = '';

  final _formKey = GlobalKey<FormState>();
  bool _acceptTerms = false;

  void _handleRegister(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState!.validate() && isPasswordValid(password)) {
      context.read<RegisterController>().register(
            name: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
          );
    }
  }

  @override
  void initState() {
    super.initState();
    di<IAnalyticsRepository>().logEvent(
      RegisterStartEvent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return BlocProvider(
      create: (_) => RegisterController(
        di<RegisterUsecase>(),
        di<IAnalyticsRepository>(),
      ),
      child: BlocListener<RegisterController, RegisterControllerState?>(
        listener: (context, state) {
          if (state is RegisterControllerSuccess) {
            context.go('/user-preferences');
            showSnackBar(
              context,
              appTexts.registerSuccess,
            );
          } else if (state is RegisterControllerFailed) {
            var msg = '';

            if (state.message == registerFailedCodeError) {
              msg = appTexts.registerFailed;
            } else {
              msg = state.message ?? appTexts.somethingWentWrong;
            }

            showSnackBar(
              context,
              msg,
              isError: true,
            );
          }
        },
        child: Scaffold(
          body: Builder(builder: (contextBuilder) {
            return SafeArea(
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
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Gap(10),
                            HeadTitle(
                              title: appTexts.createAnAccount,
                              subTitle: appTexts.registerDetails,
                            ),
                            const Gap(20),
                            FormFieldWithLabel(
                              label: appTexts.name,
                              hintText: appTexts.enterName,
                              controller: _nameController,
                              validator: (value) =>
                                  nonEmptyStringValidator(value, appTexts),
                              keyboardType: TextInputType.name,
                            ),
                            const Gap(10),
                            FormFieldWithLabel(
                              label: appTexts.email,
                              hintText: appTexts.enterEmail,
                              controller: _emailController,
                              validator: (value) =>
                                  emailValidator(value, appTexts),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const Gap(10),
                            FormFieldWithLabel(
                              label: appTexts.password,
                              hintText: appTexts.enterPassword,
                              controller: _passwordController,
                              validator: null,
                              inputType: InputType.password,
                              keyboardType: TextInputType.visiblePassword,
                              onChange: (passwordValue) {
                                setState(() {
                                  password = passwordValue;
                                });
                              },
                            ),
                            const Gap(10),
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    appTexts.passwordRequirement,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      height: 16.5 / 12,
                                      color: isPasswordValid(password)
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                  const Gap(4),
                                  _PasswordCheck(
                                    label: appTexts.passwordLength,
                                    isCorrect:
                                        password.length >= _passwordMinLength,
                                  ),
                                  _PasswordCheck(
                                    label: appTexts.atLeastOneNumber,
                                    isCorrect:
                                        password.contains(RegExp(r'[0-9]')),
                                  ),
                                  _PasswordCheck(
                                    label: appTexts.atLeastOneUpperCaseLetter,
                                    isCorrect:
                                        password.contains(RegExp(r'[A-Z]')),
                                  ),
                                ],
                              ),
                            ),
                            _CheckBoxReglement(
                              (value) {
                                setState(() {
                                  _acceptTerms = value;
                                });
                              },
                            ),
                            const Gap(10),
                            MainBtn(
                              text: appTexts.signUp,
                              showRightIcon: true,
                              onPressed: _acceptTerms
                                  ? () => _handleRegister(contextBuilder)
                                  : null,
                            ),
                            const Gap(10.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 50,
                                  height: 1,
                                  decoration: const BoxDecoration(
                                      color: Color(0xFFD9D9D9)),
                                ),
                                const Gap(7),
                                Text(appTexts.signInWith,
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                        color: const Color(0xFFD9D9D9))),
                                const Gap(7),
                                Container(
                                  width: 50,
                                  height: 1,
                                  decoration: const BoxDecoration(
                                      color: Color(0xFFD9D9D9)),
                                ),
                              ],
                            ),
                            const Gap(10.0),
                            BlocBuilder<RegisterController,
                                RegisterControllerState?>(
                              builder: (context, state) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        context
                                            .read<RegisterController>()
                                            .googleSignIn();
                                      },
                                      child: Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: const Color(0xFF696969)
                                                      .withValues(alpha: 0.1),
                                                  offset: const Offset(0, 0),
                                                  blurRadius: 5,
                                                  spreadRadius: 3)
                                            ]),
                                        child: Center(
                                          child: SvgPicture.asset(
                                              'assets/icon/google_btn.svg'),
                                        ),
                                      ),
                                    ),
                                    const Gap(25),
                                    GestureDetector(
                                      onTap: () {
                                        context
                                            .read<RegisterController>()
                                            .appleSignIn();
                                      },
                                      child: Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: const Color(0xFF696969)
                                                      .withValues(alpha: 0.1),
                                                  offset: const Offset(0, 0),
                                                  blurRadius: 5,
                                                  spreadRadius: 3)
                                            ]),
                                        child: Center(
                                          child: SvgPicture.asset(
                                              'assets/icon/apple.svg'),
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Visibility(
                      visible: MediaQuery.of(context).viewInsets.bottom == 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(
                            child: AuthBottomAction(
                              firstText: '${appTexts.alreadyAMember} ',
                              secondText: appTexts.signIn,
                              onPressed: () {
                                context.go('/login');
                              },
                            ),
                          ),
                          const Gap(8),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _PasswordCheck extends StatelessWidget {
  const _PasswordCheck({
    required this.label,
    required this.isCorrect,
  });

  final String label;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCorrect ? Icons.check : Icons.close,
            color: isCorrect ? Colors.green : Colors.red,
            size: 15,
          ),
          const Gap(5),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w400,
              fontSize: 12,
              height: 16.5 / 12,
              color: isCorrect ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

final headTitleStyle = GoogleFonts.poppins(
  fontWeight: FontWeight.w600,
  fontSize: 20,
  height: 30 / 20,
  color: Colors.black,
);

class HeadTitle extends StatelessWidget {
  const HeadTitle({
    super.key,
    required this.title,
    required this.subTitle,
  });

  final String title;
  final String subTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: headTitleStyle,
        ),
        const Gap(5),
        Text(
          subTitle,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w400,
            fontSize: 11,
            height: 16.5 / 11,
            color: const Color(0xff121212),
          ),
        ),
      ],
    );
  }
}

class _CheckBoxReglement extends StatefulWidget {
  const _CheckBoxReglement(
    this.onChanged,
  );

  final Function(bool) onChanged;

  @override
  State<_CheckBoxReglement> createState() => _CheckBoxReglementState();
}

class _CheckBoxReglementState extends State<_CheckBoxReglement> {
  bool value = false;
  final termsAndConditionsUrl = di<RemoteConfigDataSource>().getString(
    'termsAndConditionsUrl',
  );

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox.adaptive(
          value: value,
          activeColor: orangeVariantColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
            side: const BorderSide(
              width: 1,
              color: orangeVariantColor,
            ),
          ),
          onChanged: (bool? newValue) {
            setState(() {
              value = newValue!;
              widget.onChanged(value);
            });
          },
        ),
        InkWell(
          onTap: () => launchUrlFunc(termsAndConditionsUrl),
          child: Text(
            appTexts.acceptTermsAndConditions,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w400,
              fontSize: 11,
              height: 16.5 / 11,
              color: orangeVariantColor,
            ),
          ),
        ),
      ],
    );
  }
}
