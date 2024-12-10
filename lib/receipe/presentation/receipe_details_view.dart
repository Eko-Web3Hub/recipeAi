import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/user_preferences/presentation/user_preference_question_widget.dart';
import 'package:recipe_ai/utils/app_text.dart';
import 'package:recipe_ai/utils/colors.dart';

class ReceipeDetailsView extends StatelessWidget {
  const ReceipeDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: const BoxDecoration(
              color: Color(0xffEBEBEB),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
          ),
          const Gap(7.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Burger Healthy',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 20.0,
                height: 30 / 20,
                color: blackVariantColor,
              ),
            ),
          ),
          const Gap(36.0),
          ExpansionTile(
            title: Text(
              AppText.ingredients,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                height: 24 / 16,
                color: blackVariantColor,
              ),
            ),
            children: [],
          ),
        ],
      ),
    );
  }
}

class _DisplayIngredients extends StatelessWidget {
  const _DisplayIngredients({
    required this.ingredient,
    required this.quantity,
  });

  final String ingredient;
  final String quantity;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CheckBoxOption(
          option: ingredient,
          onChanged: (isSelected) {},
        )
      ],
    );
  }
}
