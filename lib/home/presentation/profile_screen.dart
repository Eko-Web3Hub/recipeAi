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
import 'package:recipe_ai/home/presentation/signout_btn_controlller.dart';
import 'package:recipe_ai/home/presentation/translated_text.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/app_version.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/device_info.dart';
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<UserPersonnalInfo?>(
                stream: di<IUserPersonnalInfoService>().watch(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return _UserProfilCard(
                      email: '${di<IAuthUserService>().currentUser!.email}',
                      name: snapshot.data!.name,
                    );
                  }

                  return SizedBox.shrink();
                },
              ),
              const Gap(24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TranslatedText(
                    textSelector: (lang) => lang.myFavorites,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        height: 1.30,
                        color: newNeutralBlackColor),
                  ),
                  TranslatedText(
                    textSelector: (lang) => lang.seeAll,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      height: 1.30,
                      color: greenBrandColor,
                    ),
                  ),
                ],
              ),
              const Gap(12.0),
              const _FavoriteRecipeGridDisplay(),
              // _ProfilOption(
              //   icon: 'assets/icon/accountIcon.svg',
              //   onPressed: () => context.push(
              //     '/profil-screen/my-account',
              //   ),
              //   child: TranslatedText(
              //     textSelector: (lang) => lang.myAccount,
              //     style: _optionStyle,
              //   ),
              // ),
              // ListenableBuilder(
              //     listenable: di<TranslationController>(),
              //     builder: (context, _) {
              //       return _ProfilOption(
              //         icon: 'assets/icon/languagesIcon.svg',
              //         onPressed: () => context.push(
              //           '/profil-screen/change-language',
              //         ),
              //         trailing: OptionRightBtn(
              //           value: appLanguagesItem
              //               .firstWhere((item) =>
              //                   item.key ==
              //                   (appLanguagesItem.firstWhere(
              //                     (item) =>
              //                         item.key ==
              //                         di<TranslationController>()
              //                             .currentLanguageEnum
              //                             .name,
              //                   )).key)
              //               .label,
              //           onTap: () {},
              //         ),
              //         child: TranslatedText(
              //           textSelector: (lang) => lang.language,
              //           style: _optionStyle,
              //         ),
              //       );
              //     }),

              // TranslatedText(
              //   textSelector: (lang) => lang.kitchenSettings,
              //   style: _optionStyle,
              // ),
              // _ProfilOption(
              //   icon: 'assets/icon/myPreferencesIcon.svg',
              //   onPressed: () =>
              //       context.push("/profil-screen/update-user-preference"),
              //   child: TranslatedText(
              //     textSelector: (lang) => lang.myPreferences,
              //     style: _optionStyle,
              //   ),
              // ),
              // _ProfilOption(
              //   icon: 'assets/icon/notificationBell.svg',
              //   onPressed: null,
              //   child: TranslatedText(
              //     textSelector: (lang) => lang.notification,
              //     style: _optionStyle,
              //   ),
              // ),
              // const Gap(20),
              // TranslatedText(
              //   textSelector: (lang) => lang.help,
              //   style: settingHeadTitleStyle,
              // ),
              // _ProfilOption(
              //   icon: 'assets/icon/solarBugIcon.svg',
              //   onPressed: _openFeedBackLink,
              //   child: TranslatedText(
              //     textSelector: (lang) => lang.sendABug,
              //     style: _optionStyle,
              //   ),
              // ),
              // const Gap(10),
              // BlocProvider(
              //   create: (context) => SignOutBtnControlller(
              //     di<IAuthService>(),
              //   ),
              //   child: BlocBuilder<SignOutBtnControlller, SignOutBtnState>(
              //       builder: (context, btnLogOutState) {
              //     return Builder(builder: (context) {
              //       return ListenableBuilder(
              //           listenable: di<TranslationController>(),
              //           builder: (context, _) {
              //             return MainBtn(
              //               text: di<TranslationController>()
              //                   .currentLanguage
              //                   .signOut,
              //               isLoading: btnLogOutState is SignOutBtnLoading,
              //               onPressed: () {
              //                 context.read<SignOutBtnControlller>().signOut();
              //               },
              //             );
              //           });
              //     });
              //   }),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteRecipeGridDisplay extends StatelessWidget {
  const _FavoriteRecipeGridDisplay();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      primary: false,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemBuilder: (context, index) {
        return _RecipeCard();
      },
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(0xffFBFBFB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 88,
            decoration: BoxDecoration(
              color: Color(
                0xffCCD4DE,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const Gap(12),
          Text(
            'Pasta',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              height: 1.35,
              color: newNeutralBlackColor,
            ),
          ),
        ],
      ),
    );
  }
}

class ProfilActionAppBar extends StatelessWidget {
  const ProfilActionAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 20.0,
      ),
      child: GestureDetector(
        onTap: () => context.push('/profil-screen/settings'),
        child: SvgPicture.asset('assets/images/settingProfilIcon.svg'),
      ),
    );
  }
}

class _UserProfilCard extends StatelessWidget {
  const _UserProfilCard({
    required this.email,
    required this.name,
  });

  final String email;
  final String name;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        height: 80,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Color(0xff063336).withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 16,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Color(0xffCCD4DE),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: greenBrandColor,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      name[0].toUpperCase(),
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                ),
                const Gap(16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: newNeutralBlackColor,
                      ),
                    ),
                    SizedBox(
                      width: 122,
                      child: Text(
                        email,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: newNeutralGreyColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            _ArrowRight(),
          ],
        ),
      ),
    );
  }
}

class _ArrowRight extends StatelessWidget {
  const _ArrowRight();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsGeometry.all(8),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Color(0xff353535),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SvgPicture.asset(
        'assets/images/arrowWhiteIcon.svg',
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
    this.trailing,
    required this.onPressed,
    required this.child,
  });

  final String icon;

  final VoidCallback? onPressed;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPressed,
      leading: SvgPicture.asset(icon),
      trailing: trailing,
      title: child,
      contentPadding: EdgeInsets.zero,
    );
  }
}

TextStyle _optionStyle = GoogleFonts.poppins(
  fontSize: 14,
  color: Colors.black,
);
