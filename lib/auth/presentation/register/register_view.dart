import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/auth/application/register_usecase.dart';
import 'package:recipe_ai/auth/presentation/components/auth_bottom_action.dart';
import 'package:recipe_ai/auth/presentation/components/custom_snack_bar.dart';
import 'package:recipe_ai/auth/presentation/components/form_field_with_label.dart';
import 'package:recipe_ai/auth/presentation/components/main_btn.dart';
import 'package:recipe_ai/auth/presentation/register/register_controller.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/utils/app_text.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/functions.dart';
import 'package:recipe_ai/utils/remote_config_data_source.dart';

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
  final _formKey = GlobalKey<FormState>();
  bool _acceptTerms = false;

  void _handleRegister(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      // Register user
      context.read<RegisterController>().register(
            name: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterController(
        di<RegisterUsecase>(),
      ),
      child: BlocListener<RegisterController, RegisterControllerState?>(
        listener: (context, state) {
          if (state is RegisterControllerSuccess) {
            context.go('/user-preferences');
            showSnackBar(
              context,
              AppText.registerSuccess,
            );
          } else if (state is RegisterControllerFailed) {
            showSnackBar(
              context,
              state.message!,
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
                            const HeadTitle(
                              title: AppText.createAnAccount,
                              subTitle: AppText.registerDetails,
                            ),
                            const Gap(20),
                            FormFieldWithLabel(
                              label: AppText.name,
                              hintText: AppText.enterName,
                              controller: _nameController,
                              validator: nonEmptyStringValidator,
                              keyboardType: TextInputType.name,
                            ),
                            const Gap(10),
                            FormFieldWithLabel(
                              label: AppText.email,
                              hintText: AppText.enterEmail,
                              controller: _emailController,
                              validator: emailValidator,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const Gap(10),
                            FormFieldWithLabel(
                              label: AppText.password,
                              hintText: AppText.enterPassword,
                              controller: _passwordController,
                              validator: passwordValidator,
                              inputType: InputType.password,
                              keyboardType: TextInputType.visiblePassword,
                            ),
                            const Gap(10),
                            FormFieldWithLabel(
                              label: AppText.confirmPassword,
                              hintText: AppText.enterConfirmPassword,
                              controller: _passwordConfirmController,
                              validator: (value) => confirmPasswordValidator(
                                value,
                                _passwordController.text,
                              ),
                              inputType: InputType.password,
                              keyboardType: TextInputType.visiblePassword,
                            ),
                            _CheckBoxReglement(
                              (value) {
                                setState(() {
                                  _acceptTerms = value;
                                });
                              },
                            ),
                            const Gap(20),
                            MainBtn(
                              text: AppText.signUp,
                              showRightIcon: true,
                              onPressed: _acceptTerms
                                  ? () => _handleRegister(contextBuilder)
                                  : null,
                            ),
                            // const Spacer(),
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
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            height: 30 / 20,
            color: Colors.black,
          ),
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
            AppText.acceptTermsAndConditions,
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
