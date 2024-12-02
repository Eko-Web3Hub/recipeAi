import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class MainBtn extends StatelessWidget {
  const MainBtn({
    super.key,
    required this.text,
    this.showRightIcon = false,
    this.onPressed,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool showRightIcon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            text,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              height: 24 / 16,
              color: Colors.white,
            ),
          ),
          Visibility(
            visible: showRightIcon,
            child: const Padding(
              padding: EdgeInsets.only(left: 30.0),
              child: _ArrowIconWidget(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArrowIconWidget extends StatelessWidget {
  const _ArrowIconWidget();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      "assets/images/ArrowRightIcon.svg",
    );
  }
}
