import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/auth/presentation/components/auth_bottom_action.dart';
import 'package:recipe_ai/auth/presentation/components/form_field_with_label.dart';
import 'package:recipe_ai/auth/presentation/components/main_btn.dart';
import 'package:recipe_ai/utils/app_text.dart';
import 'package:recipe_ai/utils/constant.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: horizontalScreenPadding,
          ),
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
              ),
              const Gap(30.0),
              FormFieldWithLabel(
                label: AppText.password,
                hintText: AppText.enterPassword,
                controller: _passwordController,
              ),
              const Gap(50.0),
              MainBtn(
                text: AppText.signIn,
                showRightIcon: true,
                onPressed: () {},
              ),
              const Gap(30.0),
              const Spacer(),
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
