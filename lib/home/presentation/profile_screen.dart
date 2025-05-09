import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/auth/application/auth_service.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/application/user_personnal_info_service.dart';
import 'package:recipe_ai/auth/domain/model/user_personnal_info.dart';
import 'package:recipe_ai/auth/presentation/components/main_btn.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/home/presentation/account_screen.dart';
import 'package:recipe_ai/home/presentation/home_screen.dart';
import 'package:recipe_ai/home/presentation/signout_btn_controlller.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/app_version.dart';
import 'package:recipe_ai/utils/device_info.dart';
import 'package:recipe_ai/utils/functions.dart';
import 'package:url_launcher/url_launcher.dart';

TextStyle settingHeadTitleStyle = GoogleFonts.poppins(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  color: Colors.black,
);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.withValues(alpha: 0.4),
                child: const UserFirstNameCharOnCapitalCase(),
              ),
              const Gap(15.0),
              StreamBuilder<UserPersonnalInfo?>(
                stream: di<IUserPersonnalInfoService>().watch(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Text(
                      capitalizeFirtLetter(snapshot.data!.name),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }

                  return SizedBox.shrink();
                },
              ),
              const Gap(20),
              Text(
                appTexts.baseSettings,
                style: settingHeadTitleStyle,
              ),
              _ProfilOption(
                icon: 'assets/icon/accountIcon.svg',
                title: appTexts.myAccount,
                onPressed: () => context.push(
                  '/profil-screen/my-account',
                ),
              ),
              _ProfilOption(
                icon: 'assets/icon/languagesIcon.svg',
                title: appTexts.language,
                onPressed: () => context.push(
                  '/profil-screen/change-language',
                ),
                trailing: OptionRightBtn(
                  value: appLanguagesItem
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
                  onTap: () {},
                ),
              ),
              const Gap(20),
              Text(
                appTexts.kitchenSettings,
                style: settingHeadTitleStyle,
              ),
              _ProfilOption(
                icon: 'assets/icon/myPreferencesIcon.svg',
                title: appTexts.myPreferences,
                onPressed: () =>
                    context.push("/profil-screen/update-user-preference"),
              ),
              _ProfilOption(
                icon: 'assets/icon/notificationBell.svg',
                title: appTexts.notification,
                onPressed: null,
              ),
              const Gap(20),
              Text(
                appTexts.help,
                style: settingHeadTitleStyle,
              ),
              _ProfilOption(
                icon: 'assets/icon/solarBugIcon.svg',
                title: appTexts.sendABug,
                onPressed: _openFeedBackLink,
              ),
              const Gap(10),
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
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.white,
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

class PopupTitle extends StatelessWidget {
  const PopupTitle({
    super.key,
    required this.title,
  });

  final String title;
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 17,
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class AppLanguageItem {
  final String label;
  final String key;

  AppLanguageItem({
    required this.label,
    required this.key,
  });
}

final appLanguagesItem = [
  AppLanguageItem(label: 'English', key: 'en'),
  AppLanguageItem(label: 'Français', key: 'fr'),
];

class _ProfilOption extends StatelessWidget {
  const _ProfilOption({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onPressed,
  });

  final String icon;
  final String title;
  final VoidCallback? onPressed;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPressed,
      leading: SvgPicture.asset(icon),
      trailing: trailing,
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.black,
        ),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}
