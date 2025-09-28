import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/application/user_personnal_info_service.dart';
import 'package:recipe_ai/auth/domain/model/user_personnal_info.dart';
import 'package:recipe_ai/auth/presentation/components/custom_snack_bar.dart';
import 'package:recipe_ai/auth/presentation/components/form_field_with_label.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/home/presentation/delete_account_after_an_login.dart';
import 'package:recipe_ai/home/presentation/delete_account_controller.dart';
import 'package:recipe_ai/home/presentation/profile_screen.dart';
import 'package:recipe_ai/kitchen/presentation/kitchen_inventory_screen.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/functions.dart';
import 'package:recipe_ai/utils/styles.dart';
import 'package:recipe_ai/l10n/app_localizations.dart';

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

class AccountDeleteMetadata implements ILoginAgainDialogMetadata {
  AccountDeleteMetadata({
    required this.context,
    required this.appTexts,
    required this.firebaseAuth,
  });

  @override
  void onSuccess() {
    context.go('/onboarding/start');
    showSnackBar(
      context,
      appTexts.deleteAccountSuccess,
    );
  }

  final BuildContext context;
  final AppLocalizations appTexts;
  final IFirebaseAuth firebaseAuth;

  @override
  void onError() {
    showSnackBar(
      context,
      appTexts.deleteAccountError,
      isError: true,
    );
  }

  @override
  String get popupTitle => appTexts.deleteAccountIncorrectPassword;

  @override
  String get actionBtnText => appTexts.delete;

  @override
  Future<void> onMainBtnPressed() => firebaseAuth.deleteAccount();
}

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final TextEditingController _nameController = TextEditingController();

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
      builder: (BuildContext context) => LoginAgainDialog(
        metadata: AccountDeleteMetadata(
          context: context,
          appTexts: di<TranslationController>().currentLanguage,
          firebaseAuth: di<IFirebaseAuth>(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return BlocProvider(
      create: (_) => DeleteAccountController(
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
          child: Scaffold(
            appBar: KitchenInventoryAppBar(
              title: appTexts.editProfile,
              arrowLeftOnPressed: () => context.pop(),
            ),
            body: Padding(
              padding: EdgeInsets.only(
                left: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(10.0),
                  StreamBuilder<UserPersonnalInfo?>(
                    stream: di<IUserPersonnalInfoService>().watch(),
                    builder: (context, snapshot) {
                      final name = snapshot.hasData && snapshot.data != null
                          ? snapshot.data!.name
                          : null;
                      _nameController.text = name ?? '';

                      print(name);

                      return Column(
                        children: [
                          Center(
                            child: UserProfilePicture(
                              size: 120,
                              name: name,
                            ),
                          ),
                          const Gap(32.0),
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 20.0,
                            ),
                            child: GestureDetector(
                              onTap: () => context.push(
                                '/profil-screen/change-username',
                              ),
                              child: NewFormField(
                                label: appTexts.name,
                                initialValue: null,
                                enabled: false,
                                controller: _nameController,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const Gap(12.0),
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 20.0,
                    ),
                    child: GestureDetector(
                      onTap: () => context.push(
                        '/profil-screen/change-email',
                      ),
                      child: NewFormField(
                        label: appTexts.email,
                        initialValue:
                            di<IAuthUserService>().currentUser!.email!,
                        enabled: false,
                        controller: null,
                      ),
                    ),
                  ),
                  const Gap(12.0),
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 20.0,
                    ),
                    child: GestureDetector(
                      onTap: () =>
                          context.push('/profil-screen/change-password'),
                      child: NewFormField(
                        label: appTexts.password,
                        initialValue: '********',
                        enabled: false,
                        controller: null,
                      ),
                    ),
                  ),
                  const Gap(12.0),
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
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

const _kGreyColor = Color(
  0xff797979,
);

class _AccountOption extends StatelessWidget {
  const _AccountOption({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          OptionRightBtn(
            value: value,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

class OptionRightBtn extends StatelessWidget {
  const OptionRightBtn({
    super.key,
    required this.value,
    required this.onTap,
  });

  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w400,
            fontSize: 11,
            color: _kGreyColor,
          ),
        ),
        const Gap(5.0),
        IconButton(
          onPressed: onTap,
          icon: const Icon(
            Icons.arrow_forward_ios,
            color: _kGreyColor,
            size: 16,
          ),
        ),
      ],
    );
  }
}

abstract class ILoginAgainDialogMetadata {
  String get popupTitle;
  String get actionBtnText;

  Future<void> onMainBtnPressed();
  void onSuccess();
  void onError();
}

class LoginAgainDialog extends StatefulWidget {
  const LoginAgainDialog({
    super.key,
    required this.metadata,
  });

  final ILoginAgainDialogMetadata metadata;

  @override
  State<LoginAgainDialog> createState() => _LoginAgainDialogState();
}

class _LoginAgainDialogState extends State<LoginAgainDialog> {
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
          widget.metadata.onMainBtnPressed,
        ),
        child: BlocListener<DeleteAccountAfterAnLoginController,
            DeleteAccountAfterAnLoginState>(
          listener: (context, state) {
            if (state is DeleteAccountAfterAnLoginSuccess) {
              Navigator.of(context).pop();
              widget.metadata.onSuccess();
            } else if (state is DeleteAccountAfterAnErrorOcured) {
              widget.metadata.onError();
            }
          },
          child: Builder(builder: (context) {
            return Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.metadata.popupTitle,
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
                            widget.metadata.popupTitle,
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
                          widget.metadata.actionBtnText,
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
    return GestureDetector(
      onTap: onPressed,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: textColor ?? Colors.black,
        ),
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
          PopupTitle(
            title: appTexts.confirmAccountDeletion,
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

final _formBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(
    16.0,
  ),
  borderSide: BorderSide(
    width: 1.5,
    color: newNeutralBlackColor,
  ),
);

class NewFormField extends StatelessWidget {
  const NewFormField({
    super.key,
    required this.label,
    this.prefixIcon,
    this.initialValue,
    this.controller,
    this.enabled = true,
    this.onTap,
  });

  final String label;
  final String? initialValue;
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final bool enabled;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w400,
            fontSize: 16,
            height: 1.35,
            color: newNeutralBlackColor,
          ),
        ),
        const Gap(12.0),
        TextFormField(
          onTap: onTap,
          controller: controller,
          initialValue: initialValue,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: newNeutralBlackColor,
            height: 1.45,
          ),
          decoration: InputDecoration(
            enabled: enabled,
            prefixIcon: prefixIcon,
            disabledBorder: _formBorder,
            border: _formBorder,
          ),
        ),
      ],
    );
  }
}
