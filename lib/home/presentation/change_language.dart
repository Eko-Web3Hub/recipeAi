import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/home/presentation/profile_screen.dart';
import 'package:recipe_ai/kitchen/presentation/kitchen_inventory_screen.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/constant.dart';

class ChangeLanguageScreen extends StatefulWidget {
  const ChangeLanguageScreen({super.key});

  @override
  State<ChangeLanguageScreen> createState() => _ChangeLanguageScreenState();
}

class _ChangeLanguageScreenState extends State<ChangeLanguageScreen> {
  late AppLanguageItem _currentAppLanguageItem;

  @override
  void initState() {
    super.initState();

    _currentAppLanguageItem = appLanguagesItem.firstWhere(
      (item) =>
          item.key == di<TranslationController>().currentLanguageEnum.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return Scaffold(
      appBar: KitchenInventoryAppBar(
        title: appTexts.selectLanguage,
        arrowLeftOnPressed: () => context.pop(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: verticalScreenPadding,
        ),
        child: Column(
          children: [
            const Gap(25.0),
            DropdownButton<AppLanguageItem>(
              isExpanded: true,
              value: _currentAppLanguageItem,
              items: appLanguagesItem
                  .map((item) => DropdownMenuItem<AppLanguageItem>(
                        value: item,
                        child: Text(
                          item.label,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (newItem) {
                if (newItem != null) {
                  setState(() {
                    _currentAppLanguageItem = newItem;
                  });
                  di<TranslationController>().changeLanguage(newItem.key);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
