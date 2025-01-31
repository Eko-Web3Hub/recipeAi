import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/auth/presentation/components/form_field_with_label.dart';
import 'package:recipe_ai/auth/presentation/components/main_btn.dart';
import 'package:recipe_ai/auth/presentation/register/register_view.dart';
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
    return Scaffold(
      body: Padding(
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
              MainBtn(
                text: AppText.validate,
                onPressed: () {},
              ),
              const Gap(30),
            ],
          ),
        ),
      ),
    );
  }
}
