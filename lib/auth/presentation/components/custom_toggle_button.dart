import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/utils/colors.dart';

enum InitialAlign { left, right }

// ignore: must_be_immutable
class CustomToggleButton extends StatefulWidget {
  final String leftContent;
  final String rightContent;
  final Function(int index) onToggle;
  InitialAlign initialAlign;

  CustomToggleButton(
      {super.key,
      required this.leftContent,
      required this.rightContent,
      required this.onToggle,
      this.initialAlign = InitialAlign.left});

  @override
  CustomToggleButtonState createState() => CustomToggleButtonState();
}

const double width = 350.0;
const double height = 56;
const double leftAlign = -1;
const double rightAlign = 1;
const Color selectedColor = Colors.white;
const Color normalColor = newNeutralBlackColor;

class CustomToggleButtonState extends State<CustomToggleButton> {
  late double xAlign;
  late Color leftColor;
  late Color rightColor;
  Color leftIconColor = Colors.white;
  Color rightIconColor = const Color(0xFFAFAFAF);
  FontWeight leftFontWeight = FontWeight.w700;
  FontWeight rightFontWeight = FontWeight.w400;

  @override
  void initState() {
    super.initState();
    xAlign = widget.initialAlign == InitialAlign.left ? leftAlign : rightAlign;
    leftColor =
        widget.initialAlign == InitialAlign.left ? selectedColor : normalColor;
    rightColor =
        widget.initialAlign == InitialAlign.right ? selectedColor : normalColor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: const BoxDecoration(
        color: neutralGrey4Color,
        borderRadius: BorderRadius.all(
          Radius.circular(16),
        ),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: Alignment(xAlign, 0),
            duration: const Duration(milliseconds: 300),
            child: Container(
              width: width * 0.5,
              margin: const EdgeInsets.all(3),
              height: height,
              decoration: const BoxDecoration(
                color: orangePrimaryColor,
                borderRadius: BorderRadius.all(
                  Radius.circular(16),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                xAlign = leftAlign;
                leftColor = selectedColor;
                rightColor = normalColor;
                leftIconColor = selectedColor;
                rightIconColor = const Color(0xFF9FACBD);
                leftFontWeight = FontWeight.w700;
                rightFontWeight = FontWeight.w400;
                widget.onToggle(0);
              });
            },
            child: Align(
              alignment: const Alignment(-1, 0),
              child: Container(
                width: width * 0.5,
                color: Colors.transparent,
                alignment: Alignment.center,
                child: Text(
                  widget.leftContent,
                  style: GoogleFonts.poppins(
                    color: leftColor,
                    fontSize: 12,
                    fontWeight: leftFontWeight,
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                xAlign = rightAlign;
                rightColor = selectedColor;

                leftColor = normalColor;
                rightIconColor = selectedColor;
                leftIconColor = const Color(0xFF9FACBD);
                leftFontWeight = FontWeight.w400;
                rightFontWeight = FontWeight.w700;
                widget.onToggle(1);
              });
            },
            child: Align(
              alignment: const Alignment(1, 0),
              child: Container(
                width: width * 0.5,
                color: Colors.transparent,
                alignment: Alignment.center,
                child: Text(
                  widget.rightContent,
                  style: GoogleFonts.poppins(
                    color: rightColor,
                    fontSize: 12,
                    fontWeight: rightFontWeight,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
