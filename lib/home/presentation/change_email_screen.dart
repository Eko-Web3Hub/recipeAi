import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/auth/application/user_personnal_info_service.dart';
import 'package:recipe_ai/auth/presentation/components/custom_text_form_field.dart';
import 'package:recipe_ai/auth/presentation/components/main_btn.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/home/presentation/change_username.dart';
import 'package:recipe_ai/home/presentation/email_loader.dart';
import 'package:recipe_ai/kitchen/presentation/kitchen_inventory_screen.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/constant.dart';

class ChangeEmailScreen extends StatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return Scaffold(
      appBar: KitchenInventoryAppBar(
        title: appTexts.changeEmail,
        arrowLeftOnPressed: () => context.pop(),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: verticalScreenPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(25.0),
            Text(
              appTexts.changeEmailDescription,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
              textAlign: TextAlign.start,
            ),
            const Gap(10),
            BlocProvider(
              create: (_) => EmailLoader(
                di<IUserPersonnalInfoService>(),
              ),
              child: BlocBuilder<EmailLoader, String?>(
                builder: (context, email) {
                  if (email != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _emailController.text = email;
                    });
                  }

                  return CustomTextFormField(
                    hintText: '',
                    controller: _emailController,
                    validator: null,
                    isReadOnly: true,
                  );
                },
              ),
            ),
            const Spacer(),
            MainBtn(
              text: appTexts.getTheLink,
            ),
            const Gap(kBottomProfilePadding),
          ],
        ),
      ),
    );
  }
}
