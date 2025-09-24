import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/kitchen/presentation/kitchen_inventory_screen.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/colors.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final translationController = di<TranslationController>();
    final appTexts = translationController.currentLanguage;

    return ListenableBuilder(
        listenable: translationController,
        builder: (context, _) {
          return Scaffold(
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
                    title: appTexts.notification,
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class _NotificationSetting extends StatelessWidget {
  const _NotificationSetting({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return _SettingOptionCard(
      iconPath: 'assets/images/notificationSettingIcon.svg',
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

class _SettingOptionCard extends StatelessWidget {
  const _SettingOptionCard({
    required this.iconPath,
    required this.title,
    required this.rightSectionChild,
  });

  final String iconPath;
  final String title;
  final Widget rightSectionChild;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
    );
  }
}
