import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/auth/application/auth_service.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/application/user_personnal_info_service.dart';
import 'package:recipe_ai/auth/domain/model/user_personnal_info.dart';
import 'package:recipe_ai/auth/presentation/components/custom_snack_bar.dart';
import 'package:recipe_ai/auth/presentation/components/form_field_with_label.dart';
import 'package:recipe_ai/auth/presentation/components/main_btn.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/home/presentation/delete_account_after_an_login.dart';
import 'package:recipe_ai/home/presentation/delete_account_controller.dart';
import 'package:recipe_ai/home/presentation/home_screen.dart';
import 'package:recipe_ai/home/presentation/signout_btn_controlller.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/app_version.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/device_info.dart';
import 'package:recipe_ai/utils/functions.dart';
import 'package:recipe_ai/utils/styles.dart';
import 'package:url_launcher/url_launcher.dart';

TextStyle _noTextStyle = GoogleFonts.poppins(
  color: Colors.black,
  fontWeight: FontWeight.w600,
);

TextStyle _deleteTextStyle = GoogleFonts.poppins(
  color: Colors.red,
  fontWeight: FontWeight.w600,
);

void _delectionSuccess(BuildContext context) {
  final appTexts = di<TranslationController>().currentLanguage;

  context.go('/onboarding/start');
  showSnackBar(
    context,
    appTexts.deleteAccountSuccess,
  );
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<bool?> _showConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDeleteAccountWidget(
          noPressed: () => Navigator.of(context).pop(false),
          yesPressed: () => Navigator.of(context).pop(true),
        );
      },
    );
  }

  Future<bool?> _showLoginAgainDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => const _LoginAgainDialog(),
    );
  }

  Future<void> _openFeedBackLink() async {
    final encodedUid =
        Uri.encodeComponent(di<IAuthUserService>().currentUser!.uid.value);
    final device = await deviceInfo();
    final appVersion = await getAppVersion();

    final encodedDevice = Uri.encodeComponent(device);
    final encodedAppVersion = Uri.encodeComponent(appVersion);

    final url =
        'https://tally.so/r/nGblKQ?uid=$encodedUid&device=$encodedDevice&version=$encodedAppVersion';
    final uri = Uri.parse(url);

    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return BlocProvider(
      create: (context) => DeleteAccountController(
        di<IFirebaseAuth>(),
      ),
      child: Builder(builder: (context) {
        return BlocListener<DeleteAccountController, DeleteAccountState>(
          listener: (context, state) {
            if (state is DeleteAccountSuccess) {
              _delectionSuccess(context);
            } else if (state is DeleteAccountRequiredRecentLogin) {
              _showLoginAgainDialog(context);
            } else if (state is DeleteAccountErrorOcuured) {
              showSnackBar(
                context,
                appTexts.deleteAccountError,
                isError: true,
              );
            }
          },
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.withValues(alpha: 0.4),
                        child: const UserFirstNameCharOnCapitalCase(),
                      ),
                      const Gap(20),
                      StreamBuilder<UserPersonnalInfo?>(
                          stream: di<IUserPersonnalInfoService>().watch(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              return Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        capitalizeFirtLetter(
                                            snapshot.data!.name),
                                        style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        )),
                                    const Gap(5),
                                    Text(
                                      snapshot.data!.email,
                                      style: GoogleFonts.poppins(
                                          color: const Color(0xFF797979)),
                                    )
                                  ],
                                ),
                              );
                            }

                            return Container();
                          })
                    ],
                  ),
                  const Gap(20),
                  _TextButton(
                    text: appTexts.changesPreferences,
                    textColor: null,
                    onPressed: () {
                      context.push("/profil-screen/update-user-preference");
                    },
                  ),
                  _TextButton(
                    text: appTexts.sendABug,
                    textColor: null,
                    onPressed: () {
                      _openFeedBackLink();
                    },
                  ),
                  _TextButton(
                    text: appTexts.deleteAccount,
                    onPressed: () async {
                      final response = await _showConfirmationDialog(context);

                      if (response == true) {
                        context.read<DeleteAccountController>().deleteAccount();
                      }
                    },
                    textColor: Colors.red,
                  ),
                  const Gap(20),
                  BlocProvider(
                    create: (context) => SignOutBtnControlller(
                      di<IAuthService>(),
                    ),
                    child: BlocBuilder<SignOutBtnControlller, SignOutBtnState>(
                        builder: (context, btnLogOutState) {
                      return Builder(builder: (context) {
                        return MainBtn(
                          text: appTexts.signOut,
                          isLoading: btnLogOutState is SignOutBtnLoading,
                          onPressed: () {
                            context.read<SignOutBtnControlller>().signOut();
                          },
                        );
                      });
                    }),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _TextButton extends StatelessWidget {
  const _TextButton({
    required this.text,
    required this.textColor,
    required this.onPressed,
  });

  final String text;
  final Color? textColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        surfaceTintColor: WidgetStateProperty.all(
          Colors.white,
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: textColor ?? Colors.black,
            ),
          ),
          const Gap(10),
          Icon(
            Icons.chevron_right,
            color: textColor ?? Colors.black,
          ),
        ],
      ),
    );
  }
}

class ConfirmationDeleteAccountWidget extends StatelessWidget {
  const ConfirmationDeleteAccountWidget({
    super.key,
    required this.noPressed,
    required this.yesPressed,
  });

  final VoidCallback noPressed;
  final VoidCallback yesPressed;

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return DialogLayout(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            appTexts.confirmAccountDeletion,
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(30),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: noPressed,
                child: Text(
                  appTexts.no,
                  style: _noTextStyle,
                ),
              ),
              TextButton(
                onPressed: yesPressed,
                child: Text(
                  appTexts.delete,
                  style: _deleteTextStyle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DialogLayout extends StatelessWidget {
  const DialogLayout({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Gap(4),
            child,
          ],
        ),
      ),
    );
  }
}

class _LoginAgainDialog extends StatefulWidget {
  const _LoginAgainDialog();

  @override
  State<_LoginAgainDialog> createState() => _LoginAgainDialogState();
}

class _LoginAgainDialogState extends State<_LoginAgainDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return DialogLayout(
      child: BlocProvider(
        create: (context) => DeleteAccountAfterAnLoginController(
          di<IFirebaseAuth>(),
          di<IAuthUserService>(),
        ),
        child: BlocListener<DeleteAccountAfterAnLoginController,
            DeleteAccountAfterAnLoginState>(
          listener: (context, state) {
            if (state is DeleteAccountAfterAnLoginSuccess) {
              Navigator.of(context).pop();
              _delectionSuccess(context);
            } else if (state is DeleteAccountAfterAnErrorOcured) {
              showSnackBar(
                context,
                appTexts.deleteAccountError,
                isError: true,
              );
            }
          },
          child: Builder(builder: (context) {
            return Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    appTexts.deleteAccountRequiredRecentLogin,
                    style: titleDialogStyle,
                    textAlign: TextAlign.center,
                  ),
                  const Gap(30),
                  FormFieldWithLabel(
                    label: appTexts.password,
                    hintText: appTexts.enterPassword,
                    controller: _passwordController,
                    validator: (value) =>
                        nonEmptyStringValidator(value, appTexts),
                    inputType: InputType.password,
                    keyboardType: TextInputType.visiblePassword,
                  ),
                  BlocBuilder<DeleteAccountAfterAnLoginController,
                      DeleteAccountAfterAnLoginState>(
                    builder: (context, state) {
                      if (state is DeleteAccountAfterAnLoginIncorrectPassword) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            top: 10,
                            left: 6,
                          ),
                          child: Text(
                            appTexts.deleteAccountIncorrectPassword,
                            style: GoogleFonts.poppins(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                  const Gap(20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          appTexts.no,
                          style: _noTextStyle,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context
                                .read<DeleteAccountAfterAnLoginController>()
                                .deleteAccountAfterAReLogin(
                                  _passwordController.text,
                                );
                          }
                        },
                        child: Text(
                          appTexts.delete,
                          style: _deleteTextStyle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
