import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/presentation/components/custom_snack_bar.dart';
import 'package:recipe_ai/auth/presentation/components/main_btn.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/home/presentation/change_password_controller.dart';
import 'package:recipe_ai/kitchen/presentation/kitchen_inventory_screen.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/constant.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return BlocProvider(
      create: (_) => ChangePasswordController(
        di<IFirebaseAuth>(),
        di<IAuthUserService>(),
      ),
      child: Builder(builder: (context) {
        return BlocListener<ChangePasswordController, ChangePasswordState?>(
          listener: (context, state) {
            if (state is ChangePasswordSuccess) {
              context.pop();
              showSnackBar(
                context,
                appTexts.checkYourEmail,
              );

              return;
            }
          },
          child: Scaffold(
            appBar: KitchenInventoryAppBar(
              title: appTexts.changePassword,
              arrowLeftOnPressed: () => context.pop(),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: verticalScreenPadding,
              ),
              child: Column(
                children: [
                  const Gap(25.0),
                  Text(
                    appTexts.changePasswordDescription,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 11,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  BlocBuilder<ChangePasswordController, ChangePasswordState?>(
                    builder: (context, changePasswordState) {
                      return MainBtn(
                        isLoading: changePasswordState is ChangePasswordLoading,
                        text: appTexts.getTheLink,
                        onPressed: () => context
                            .read<ChangePasswordController>()
                            .changePassword(),
                      );
                    },
                  ),
                  const Gap(kBottomProfilePadding)
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
