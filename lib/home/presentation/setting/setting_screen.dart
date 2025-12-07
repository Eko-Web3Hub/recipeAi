import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/auth/application/auth_service.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';

import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/home/presentation/profile_screen.dart';
import 'package:recipe_ai/home/presentation/signout_btn_controlller.dart';
import 'package:recipe_ai/kitchen/presentation/kitchen_inventory_screen.dart';
import 'package:recipe_ai/notification/domain/models/notification_user.dart';
import 'package:recipe_ai/notification/presentation/notification_user_controller.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/app_version.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/device_info.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final translationController = di<TranslationController>();
    final appTexts = translationController.currentLanguage;

    return Builder(builder: (context) {
      return ListenableBuilder(
          listenable: translationController,
          builder: (context, _) {
            return Scaffold(
              appBar: KitchenInventoryAppBar(
                title: appTexts.settings,
                arrowLeftOnPressed: () => context.pop(),
              ),
              body: Padding(
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
                    _MyPreferencesSetting(
                      title: appTexts.myPreferences,
                    ),
                    const Gap(16),
                    _FeedBackSetting(
                      title: appTexts.sendABug,
                    ),
                    const Gap(16),
                    _LogOutBtn(
                      title: appTexts.signOut,
                    ),
                    const Spacer(),
                    const Gap(80),
                  ],
                ),
              ),
            );
          });
    });
  }
}

class _LogOutBtn extends StatelessWidget {
  const _LogOutBtn({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignOutBtnControlller(
        di<IAuthService>(),
      ),
      child: BlocBuilder<SignOutBtnControlller, SignOutBtnState>(
          builder: (context, btnLogOutState) {
        return Builder(builder: (context) {
          return _SettingOptionCard(
            showLeftIcon: false,
            iconPath: 'assets/images/notificationSettingIcon.svg',
            title: title,
            rightSectionChild: _RedirectionIcon(),
            onTap: () => context.read<SignOutBtnControlller>().signOut(),
          );
        });
      }),
    );
  }
}

class _MyPreferencesSetting extends StatelessWidget {
  const _MyPreferencesSetting({
    required this.title,
  });

  final String title;
  @override
  Widget build(BuildContext context) {
    return _SettingOptionCard(
      onTap: () => context.push(
        "/profil-screen/update-user-preference",
      ),
      iconPath: 'assets/icon/myPreferencesIcon.svg',
      title: title,
      rightSectionChild: _RedirectionIcon(),
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
    return BlocBuilder<NotificationUserController, NotificationUser?>(
      builder: (context, notificationSettingState) {
        return _SettingOptionCard(
          iconPath: iconPath,
          title: title,
          rightSectionChild: Switch(
            activeColor: yellowBrandColor,
            thumbColor: WidgetStateProperty.all(Colors.white),
            value: notificationSettingState?.status ==
                NotificationUserStatus.authorized,
            onChanged: (newValue) => context
                .read<NotificationUserController>()
                .toggleNotification(newValue),
          ),
        );
      },
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
          onTap: () => context.push(
            '/profil-screen/change-language',
          ),
          iconPath: 'assets/icon/languageNewIcon.svg',
          title: appTexts.language,
          rightSectionChild: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                appLanguagesItem
                    .firstWhere((item) =>
                        item.key ==
                        (appLanguagesItem.firstWhere(
                          (item) =>
                              item.key ==
                              di<TranslationController>()
                                  .currentLanguageEnum
                                  .name,
                        )).key)
                    .label,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  height: 1.45,
                  color: Color(
                    0xffCCD4DE,
                  ),
                ),
              ),
              const Gap(13),
              _RedirectionIcon(),
            ],
          ),
        );
      },
    );
  }
}

class _FeedBackSetting extends StatelessWidget {
  const _FeedBackSetting({
    required this.title,
  });

  final String title;

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
    return _SettingOptionCard(
      onTap: _openFeedBackLink,
      iconPath: 'assets/icon/solarBugIcon.svg',
      title: title,
      rightSectionChild: _RedirectionIcon(),
    );
  }
}

class _SettingOptionCard extends StatelessWidget {
  const _SettingOptionCard({
    this.onTap,
    required this.iconPath,
    required this.title,
    required this.rightSectionChild,
    this.showLeftIcon = true,
  });
  final bool showLeftIcon;
  final String iconPath;
  final String title;

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
                Visibility(
                  visible: showLeftIcon,
                  child: SvgPicture.asset(
                    iconPath,
                  ),
                ),
                const Gap(12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w400,
                    fontSize: 16.0,
                    height: 1.35,
                    color: newNeutralBlackColor,
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
  const _RedirectionIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
