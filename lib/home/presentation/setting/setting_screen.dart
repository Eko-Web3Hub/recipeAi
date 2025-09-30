import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/presentation/components/custom_snack_bar.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/home/presentation/account_screen.dart';
import 'package:recipe_ai/home/presentation/delete_account_controller.dart';
import 'package:recipe_ai/kitchen/presentation/kitchen_inventory_screen.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/colors.dart';

void _delectionSuccess(BuildContext context) {
  final appTexts = di<TranslationController>().currentLanguage;

  context.go('/onboarding/start');
  showSnackBar(
    context,
    appTexts.deleteAccountSuccess,
  );
}

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

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
    final translationController = di<TranslationController>();
    final appTexts = translationController.currentLanguage;

    return BlocProvider(
      create: (context) => DeleteAccountController(
        di<IFirebaseAuth>(),
      ),
      child: Builder(builder: (context) {
        return ListenableBuilder(
            listenable: translationController,
            builder: (context, _) {
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
                    title: appTexts.settings,
                    arrowLeftOnPressed: () => context.pop(),
                  ),
                  body: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Column(
                      children: [
                        const Gap(10),
                        _NotificationSetting(
                          iconPath: 'assets/images/notificationSettingIcon.svg',
                          title: appTexts.notification,
                        ),
                        const Gap(16),
                        _LanguageSetting(),
                        const Gap(16),
                        _DeleteAccountBtn(
                          title: appTexts.deleteAccount,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            });
      }),
    );
  }
}

class _NotificationSetting extends StatelessWidget {
  const _NotificationSetting({
    required this.title,
    required this.iconPath,
  });

  final String iconPath;
  final String title;

  @override
  Widget build(BuildContext context) {
    return _SettingOptionCard(
      iconPath: iconPath,
      title: title,
      rightSectionChild: Switch(
        activeColor: yellowBrandColor,
        thumbColor: WidgetStateProperty.all(Colors.white),
        value: true,
        onChanged: (newValue) {},
      ),
    );
  }
}

class _LanguageSetting extends StatelessWidget {
  const _LanguageSetting();

  @override
  Widget build(BuildContext context) {
    final translationController = di<TranslationController>();
    final appTexts = translationController.currentLanguage;

    return ListenableBuilder(
      listenable: translationController,
      builder: (context, _) {
        return _SettingOptionCard(
          iconPath: 'assets/icon/languageNewIcon.svg',
          title: appTexts.language,
          rightSectionChild: _RedirectionIcon(),
        );
      },
    );
  }
}

class _DeleteAccountBtn extends StatelessWidget {
  const _DeleteAccountBtn({
    required this.title,
  });

  final String title;

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

  @override
  Widget build(BuildContext context) {
    return _SettingOptionCard(
      iconPath: 'assets/icon/languagesIcon.svg',
      title: title,
      titleColor: Colors.red,
      onTap: () async {
        final response = await _showConfirmationDialog(context);

        if (response == true) {
          context.read<DeleteAccountController>().deleteAccount();
        }
      },
      rightSectionChild: Container(),
    );
  }
}

class _SettingOptionCard extends StatelessWidget {
  const _SettingOptionCard({
    this.onTap,
    required this.iconPath,
    required this.title,
    this.titleColor,
    required this.rightSectionChild,
  });

  final String iconPath;
  final String title;
  final Color? titleColor;
  final Widget rightSectionChild;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 64,
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 20,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 2),
              blurRadius: 16,
              spreadRadius: 0,
              color: Color(0xff063336).withOpacity(
                0.1,
              ),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  iconPath,
                ),
                const Gap(12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w400,
                    fontSize: 16.0,
                    height: 1.35,
                    color: titleColor ?? newNeutralBlackColor,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: 16.0,
              ),
              child: rightSectionChild,
            ),
          ],
        ),
      ),
    );
  }
}

class _RedirectionIcon extends StatelessWidget {
  const _RedirectionIcon({
    this.onTap,
  });

  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: yellowBrandColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/images/arrowWhiteRightIcon.svg',
          ),
        ),
      ),
    );
  }
}
