import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/auth/application/user_personnal_info_service.dart';
import 'package:recipe_ai/auth/domain/model/user_personnal_info.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/kitchen/presentation/kitchen_inventory_screen.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return Scaffold(
      appBar: KitchenInventoryAppBar(
        title: appTexts.myAccount,
        arrowLeftOnPressed: () => context.pop(),
      ),
      body: Padding(
        padding: EdgeInsets.only(
          left: 20,
        ),
        child: Column(
          children: [
            const Gap(10.0),
            StreamBuilder<UserPersonnalInfo?>(
              stream: di<IUserPersonnalInfoService>().watch(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _AccountOption(
                        label: appTexts.nameUser,
                        value: snapshot.data!.name,
                        onTap: null,
                      ),
                      _AccountOption(
                        label: appTexts.email,
                        value: snapshot.data!.email,
                        onTap: null,
                      ),
                    ],
                  );
                }

                return SizedBox.shrink();
              },
            ),
            _AccountOption(
              label: appTexts.password,
              value: '********',
              onTap: null,
            ),
          ],
        ),
      ),
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
    return Row(
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
        Row(
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
        ),
      ],
    );
  }
}
