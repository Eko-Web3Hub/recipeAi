import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/auth/application/auth_service.dart';
import 'package:recipe_ai/auth/presentation/components/custom_snack_bar.dart';
import 'package:recipe_ai/auth/presentation/components/form_field_with_label.dart';
import 'package:recipe_ai/auth/presentation/components/main_btn.dart';
import 'package:recipe_ai/auth/presentation/register/register_view.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/user_account/presentation/reset_password_controller.dart';
import 'package:recipe_ai/utils/app_text.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/functions.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ResetPasswordController(
        di<IAuthService>(),
      ),
      child: Builder(builder: (context) {
        return Scaffold(
          body: BlocListener<ResetPasswordController, ResetPasswordState>(
            listener: (context, resetPasswordState) {
              if (resetPasswordState is ResetPasswordSuccess) {
                // Hidden the current snackbar
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                showSnackBar(
                  context,
                  AppText.resetPasswordSuccess,
                );
                context.go('/login');
              } else if (resetPasswordState is ResetPasswordFailure) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                showSnackBar(
                  context,
                  resetPasswordState.message,
                  isError: true,
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: horizontalScreenPadding,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(40),
                    InkWell(
                      child: SvgPicture.asset(
                        'assets/images/arrow-black-left.svg',
                      ),
                      onTap: () => context.go('/login'),
                    ),
                    const Gap(10),
                    Text(
                      AppText.forgotternPassword,
                      style: headTitleStyle,
                    ),
                    const Gap(70),
                    FormFieldWithLabel(
                      label: AppText.email,
                      hintText: AppText.enterEmail,
                      controller: _emailController,
                      validator: emailValidator,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const Spacer(),
                    BlocBuilder<ResetPasswordController, ResetPasswordState>(
                      builder: (context, resetPasswordState) => MainBtn(
                        isLoading: resetPasswordState is ResetPasswordLoading,
                        text: AppText.validate,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context
                                .read<ResetPasswordController>()
                                .resetPassword(
                                  _emailController.text,
                                );
                          }
                        },
                      ),
                    ),
                    const Gap(80),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
