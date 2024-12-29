import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/auth/application/auth_service.dart';
import 'package:recipe_ai/auth/application/user_personnal_info_service.dart';
import 'package:recipe_ai/auth/domain/model/user_personnal_info.dart';
import 'package:recipe_ai/auth/presentation/components/main_btn.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/home/presentation/signout_btn_controlller.dart';
import 'package:recipe_ai/utils/app_text.dart';
import 'package:recipe_ai/utils/functions.dart';

// AppBar(
//         backgroundColor: Colors.white,
//         centerTitle: true,
//         leading: Container(),
//         title: Text(
//           'Profile',
//           style: GoogleFonts.poppins(
//             color: Colors.black,
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       )

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<bool?> _showConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: const ConfirmationDeleteAccountWidget(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.withValues(alpha: 0.4),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 55,
                    color: Colors.black,
                  ),
                ),
                const Gap(20),
                StreamBuilder<UserPersonnalInfo?>(
                    stream: di<IUserPersonnalInfoService>().watch(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  " ${capitalizeFirtLetter(snapshot.data!.name)}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  )),
                              const Gap(5),
                              Text(
                                snapshot.data!.email,
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF797979)),
                              )
                            ],
                          ),
                        );
                      }

                      return Container();
                    })
              ],
            ),
            const Gap(20),
            _TextButton(
              text: AppText.changesPreferences,
              textColor: null,
              onPressed: () {
                context.push("/user-preferences");
              },
            ),
            _TextButton(
              text: AppText.deleteAccount,
              onPressed: () async {
                final response = await _showConfirmationDialog(context);

                if (response == true) {
                  Navigator.of(context).pop();

                  /// delete account
                }
              },
              textColor: Colors.red,
            ),
            const Gap(20),
            BlocProvider(
              create: (context) => SignOutBtnControlller(
                di<IAuthService>(),
              ),
              child: BlocBuilder<SignOutBtnControlller, SignOutBtnState>(
                  builder: (context, btnLogOutState) {
                return Builder(builder: (context) {
                  return MainBtn(
                    text: 'Logout',
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
    );
  }
}

class _TextButton extends StatelessWidget {
  const _TextButton({
    required this.text,
    required this.textColor,
    required this.onPressed,
  });

  final String text;
  final Color? textColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        surfaceTintColor: WidgetStateProperty.all(
          Colors.white,
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: textColor ?? Colors.black,
            ),
          ),
          const Gap(10),
          Icon(
            Icons.chevron_right,
            color: textColor ?? Colors.black,
          ),
        ],
      ),
    );
  }
}

class ConfirmationDeleteAccountWidget extends StatelessWidget {
  const ConfirmationDeleteAccountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Gap(4),
          Text(
            AppText.confirmAccountDeletion,
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(30),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  AppText.no,
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  AppText.delete,
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
