import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/application/user_personnal_info_service.dart';
import 'package:recipe_ai/auth/domain/model/user_personnal_info.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/receipe/application/user_recipe_service.dart';
import 'package:recipe_ai/saved_receipe/presentation/saved_receipe_controller.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

TextStyle settingHeadTitleStyle = TextStyle(
  fontFamily: poppinsFontFamily,
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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SavedReceipeController(di<IUserRecipeService>()),
      child: SafeArea(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfilActionAppBar extends StatelessWidget {
  const ProfilActionAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: GestureDetector(
        onTap: () => context.push('/profil-screen/settings'),
        child: SvgPicture.asset('assets/images/settingProfilIcon.svg'),
      ),
    );
  }
}

class _UserProfilCard extends StatelessWidget {
  const _UserProfilCard({required this.email, required this.name});

  final String email;
  final String name;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/profil-screen/my-account'),
      child: Container(
        width: double.infinity,
        height: 80,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Color(0xff063336).withValues(alpha: 0.1),
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
                UserProfilePicture(name: name, size: 48),
                const Gap(16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontFamily: poppinsFontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: newNeutralBlackColor,
                      ),
                    ),
                    SizedBox(
                      width: 122,
                      child: Text(
                        email,
                        style: TextStyle(
                          fontFamily: poppinsFontFamily,
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

class UserProfilePicture extends StatelessWidget {
  const UserProfilePicture({super.key, required this.size, required this.name});

  final double size;
  final String? name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Color(0xffCCD4DE),
        shape: BoxShape.circle,
        border: Border.all(color: greenBrandColor),
      ),
      child: name == null
          ? null
          : Center(
              child: Text(
                name![0].toUpperCase(),
                style: Theme.of(context).textTheme.displayLarge,
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
      child: SvgPicture.asset('assets/images/arrowWhiteIcon.svg'),
    );
  }
}

class DialogLayout extends StatelessWidget {
  const DialogLayout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [const Gap(4), child],
        ),
      ),
    );
  }
}

class PopupTitle extends StatelessWidget {
  const PopupTitle({super.key, required this.title});

  final String title;
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: poppinsFontFamily,
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

  AppLanguageItem({required this.label, required this.key});
}

final appLanguagesItem = [
  AppLanguageItem(label: 'English', key: 'en'),
  AppLanguageItem(label: 'Français', key: 'fr'),
];
