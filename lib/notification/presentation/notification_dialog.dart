import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/auth/presentation/components/main_btn.dart';
import 'package:recipe_ai/utils/app_text.dart';

class NotificationDialog extends StatelessWidget {
  const NotificationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 14.55,
        left: 20,
        right: 20,
        bottom: 17.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () {
                log('Close dialog');
                Navigator.of(context).pop();
              },
              child: SvgPicture.asset(
                'assets/images/crossIcon.svg',
              ),
            ),
          ),
          Text(
            AppText.wantToReceiveNotification,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              height: 30 / 20,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(27.64),
          Row(
            children: [
              Expanded(
                child: MainBtn(
                  text: AppText.no,
                  height: 37,
                  onPressed: () {
                    log('No');
                    Navigator.of(context).pop(false);
                  },
                  textColor: Theme.of(context).primaryColor,
                  backgroundColor: const Color(0xffDBEBE7),
                ),
              ),
              const Gap(26),
              Expanded(
                child: MainBtn(
                  text: AppText.yes,
                  height: 37,
                  onPressed: () {
                    log('Yes');
                    Navigator.of(context).pop(true);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
