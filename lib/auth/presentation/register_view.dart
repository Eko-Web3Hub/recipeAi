import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/auth/presentation/components/auth_bottom_action.dart';
import 'package:recipe_ai/auth/presentation/components/form_field_with_label.dart';
import 'package:recipe_ai/auth/presentation/components/main_btn.dart';
import 'package:recipe_ai/utils/app_text.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

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
              const Gap(10),
              const _HeadTitle(),
              const Gap(20),
              FormFieldWithLabel(
                label: AppText.name,
                hintText: AppText.enterName,
                controller: _nameController,
              ),
              const Gap(10),
              FormFieldWithLabel(
                label: AppText.email,
                hintText: AppText.enterEmail,
                controller: _emailController,
              ),
              const Gap(10),
              FormFieldWithLabel(
                label: AppText.password,
                hintText: AppText.enterPassword,
                controller: _passwordController,
              ),
              const Gap(10),
              FormFieldWithLabel(
                label: AppText.confirmPassword,
                hintText: AppText.enterConfirmPassword,
                controller: _passwordConfirmController,
              ),
              const _CheckBoxReglement(),
              const Gap(20),
              MainBtn(
                text: AppText.signUp,
                showRightIcon: true,
                onPressed: () {},
              ),
              const Spacer(),
              Center(
                child: AuthBottomAction(
                  firstText: '${AppText.alreadyAMember} ',
                  secondText: AppText.signIn,
                  onPressed: () {
                    context.go('/login');
                  },
                ),
              ),
              const Gap(21),
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
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppText.createAnAccount,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            height: 30 / 20,
            color: Colors.black,
          ),
        ),
        const Gap(5),
        Text(
          AppText.registerDetails,
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
  const _CheckBoxReglement();

  @override
  State<_CheckBoxReglement> createState() => _CheckBoxReglementState();
}

class _CheckBoxReglementState extends State<_CheckBoxReglement> {
  bool value = false;

  @override
  Widget build(BuildContext context) {
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
            });
          },
        ),
        Text(
          AppText.acceptTermsAndConditions,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w400,
            fontSize: 11,
            height: 16.5 / 11,
            color: orangeVariantColor,
          ),
        ),
      ],
    );
  }
}
