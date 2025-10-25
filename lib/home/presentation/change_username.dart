import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/auth/application/user_personnal_info_service.dart';
import 'package:recipe_ai/auth/presentation/components/custom_snack_bar.dart';
import 'package:recipe_ai/auth/presentation/components/main_btn.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/home/presentation/account_screen.dart';
import 'package:recipe_ai/home/presentation/change_username_controller.dart';
import 'package:recipe_ai/kitchen/presentation/kitchen_inventory_screen.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/functions.dart';

class ChangeUsername extends StatefulWidget {
  const ChangeUsername({super.key});

  @override
  State<ChangeUsername> createState() => _ChangeUsernameState();
}

class _ChangeUsernameState extends State<ChangeUsername> {
  final TextEditingController _usernameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _showSnackBar(String text) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(text),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return BlocProvider(
      create: (_) => ChangeUsernameController(
        di<IUserPersonnalInfoService>(),
      ),
      child: Builder(builder: (context) {
        return BlocListener<ChangeUsernameController, ChangeUsernameState>(
          listener: (context, state) {
            if (state is ChangeUsernameLoaded && state.isChanged) {
              showSnackBar(
                context,
                appTexts.usernameChanged,
              );
              context.pop();
              return;
            }
          },
          child: Scaffold(
            appBar: KitchenInventoryAppBar(
              title: appTexts.nameUser,
              arrowLeftOnPressed: () => context.pop(),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: verticalScreenPadding,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(25.0),
                    Text(
                      appTexts.changeUsername,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    const Gap(10),
                    BlocBuilder<ChangeUsernameController, ChangeUsernameState>(
                      builder: (context, state) {
                        if (state is ChangeUsernameLoaded) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _usernameController.text = state.username;
                          });
                        }

                        return NewFormField(
                          label: null,
                          controller: _usernameController,
                          validator: (value) =>
                              nonEmptyStringValidator(value, appTexts),
                        );
                      },
                    ),
                    const Spacer(),
                    BlocBuilder<ChangeUsernameController, ChangeUsernameState>(
                      builder: (context, changeUsernameText) {
                        return MainBtn(
                          text: appTexts.validate,
                          isLoading:
                              changeUsernameText is ChangeUsernameLoading,
                          onPressed: changeUsernameText is ChangeUsernameLoaded
                              ? () {
                                  if (_formKey.currentState!.validate()) {
                                    final username = _usernameController.text;
                                    if (username ==
                                        changeUsernameText.username) {
                                      _showSnackBar(
                                          appTexts.usernameNotChanged);
                                      return;
                                    }

                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    context
                                        .read<ChangeUsernameController>()
                                        .changeUsername(username);
                                  }
                                }
                              : null,
                        );
                      },
                    ),
                    const Gap(kBottomProfilePadding),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
