import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/auth/application/auth_service.dart';
import 'package:recipe_ai/auth/presentation/components/auth_bottom_action.dart';
import 'package:recipe_ai/auth/presentation/components/custom_snack_bar.dart';
import 'package:recipe_ai/auth/presentation/components/form_field_with_label.dart';
import 'package:recipe_ai/auth/presentation/components/main_btn.dart';
import 'package:recipe_ai/auth/presentation/login_view_controller.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/utils/app_text.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/functions.dart';

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
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginViewController(
        di<IAuthService>(),
      ),
      child: BlocListener<LoginViewController, LoginViewState>(
        listener: (context, state) {
          if (state is LoginViewSuccess) {
            context.go('/home');
          } else if (state is LoginViewError) {
            showSnackBar(
              context,
              state.message ?? AppText.somethingWentWrong,
              isError: true,
            );
          }
        },
        child: Scaffold(
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
                          const Gap(50),
                          const _HeadTitle(),
                          const Gap(57),
                          FormFieldWithLabel(
                            label: AppText.email,
                            hintText: AppText.enterEmail,
                            controller: _emailController,
                            validator: nonEmptyStringValidator,
                          ),
                          const Gap(30.0),
                          FormFieldWithLabel(
                            label: AppText.password,
                            hintText: AppText.enterPassword,
                            controller: _passwordController,
                            inputType: InputType.password,
                            validator: nonEmptyStringValidator,
                          ),
                          const Gap(20),
                          InkWell(
                            onTap: () => context.go('/login/reset-password'),
                            child: Text(
                              AppText.forgotPassword,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w400,
                                fontSize: 11,
                                height: 16.5 / 11,
                                color: orangeVariantColor,
                              ),
                            ),
                          ),
                          const Gap(25.0),
                          BlocBuilder<LoginViewController, LoginViewState>(
                              builder: (context, loginControllerState) {
                            return MainBtn(
                              text: AppText.signIn,
                              showRightIcon: true,
                              isLoading:
                                  loginControllerState is LoginViewLoading,
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<LoginViewController>().login(
                                        email: _emailController.text,
                                        password: _passwordController.text,
                                      );
                                }
                              },
                            );
                          }),
                          const Gap(30.0),
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
                            firstText: AppText.dontHaveAnAccount,
                            secondText: ' ${AppText.signUp}',
                            onPressed: () {
                              context.push('/register');
                            },
                          ),
                        ),
                        const Gap(65.0),
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
        Text(
          '${AppText.hello},',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 30,
            height: 45 / 30,
          ),
        ),
        Text(
          AppText.welcomeBack,
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
