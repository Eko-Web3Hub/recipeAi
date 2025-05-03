import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/auth/application/auth_service.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/presentation/components/custom_snack_bar.dart';
import 'package:recipe_ai/auth/presentation/components/custom_text_form_field.dart';
import 'package:recipe_ai/auth/presentation/components/main_btn.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/home/presentation/account_screen.dart';
import 'package:recipe_ai/home/presentation/change_email_controller.dart';
import 'package:recipe_ai/home/presentation/change_username.dart';
import 'package:recipe_ai/kitchen/presentation/kitchen_inventory_screen.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/functions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginAgainDialogForChangeEmailMetadata
    implements ILoginAgainDialogMetadata {
  const LoginAgainDialogForChangeEmailMetadata({
    required this.appTexts,
    required this.context,
    required this.authService,
    required this.newEmail,
  });

  @override
  String get actionBtnText => appTexts.change;

  @override
  void onError() {
    showSnackBar(
      context,
      appTexts.deleteAccountError,
      isError: true,
    );
  }

  @override
  Future<void> onMainBtnPressed() => authService.changeEmail(
        newEmail,
      );

  @override
  void onSuccess() {
    context.pop();
    authService.signOut();
    showSnackBar(
      context,
      appTexts.emailChanged,
    );
  }

  @override
  String get popupTitle => appTexts.loginInAgainToChangeEmail;

  final AppLocalizations appTexts;
  final BuildContext context;
  final IAuthService authService;
  final String newEmail;
}

class ChangeEmailScreen extends StatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _oldEmail = '';

  void _showSnackBar(String text) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            text,
            style: GoogleFonts.poppins(),
          ),
        ),
      );

  Future<bool?> _showLoginAgainDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => LoginAgainDialog(
        metadata: LoginAgainDialogForChangeEmailMetadata(
          context: context,
          appTexts: di<TranslationController>().currentLanguage,
          authService: di<IAuthService>(),
          newEmail: _emailController.text,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _oldEmail = di<IAuthUserService>().currentUser?.email ?? '';
      _emailController.text = _oldEmail;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return Scaffold(
      appBar: KitchenInventoryAppBar(
        title: appTexts.changeEmail,
        arrowLeftOnPressed: () => context.pop(),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: verticalScreenPadding,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(25.0),
              Text(
                appTexts.changeEmailDescription,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
                textAlign: TextAlign.start,
              ),
              const Gap(10),
              CustomTextFormField(
                hintText: '',
                controller: _emailController,
                validator: (email) => nonEmptyStringValidator(
                  email,
                  appTexts,
                ),
              ),
              const Spacer(),
              BlocProvider(
                create: (_) => ChangeEmailController(
                  di<IAuthService>(),
                ),
                child: Builder(builder: (context) {
                  return BlocListener<ChangeEmailController, ChangeEmailState?>(
                    listener: (context, state) {
                      if (state is ChangeEmailSuccess) {
                        showSnackBar(
                          context,
                          appTexts.emailChanged,
                        );
                        context.pop();

                        return;
                      } else if (state is ChangeEmailRequiredRecentLogin) {
                        _showLoginAgainDialog(context);
                        return;
                      }
                    },
                    child:
                        BlocBuilder<ChangeEmailController, ChangeEmailState?>(
                            builder: (context, changeEmailState) {
                      return MainBtn(
                        text: appTexts.getTheLink,
                        isLoading: changeEmailState is ChangeEmailLoading,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (_emailController.text == _oldEmail) {
                              _showSnackBar(
                                appTexts.emailNotChanged,
                              );
                              return;
                            }

                            context.read<ChangeEmailController>().changeEmail(
                                  _emailController.text,
                                );
                          }
                        },
                      );
                    }),
                  );
                }),
              ),
              const Gap(kBottomProfilePadding),
            ],
          ),
        ),
      ),
    );
  }
}
