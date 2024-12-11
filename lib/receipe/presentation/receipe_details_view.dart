import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/presentation/receipe_details_controller.dart';
import 'package:recipe_ai/user_preferences/presentation/components/custom_circular_loader.dart';
import 'package:recipe_ai/user_preferences/presentation/user_preference_question_widget.dart';
import 'package:recipe_ai/utils/app_text.dart';
import 'package:recipe_ai/utils/colors.dart';

class ReceipeDetailsView extends StatelessWidget {
  const ReceipeDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReceipeDetailsController(
        const EntityId('1'),
      ),
      child: Builder(builder: (context) {
        return Scaffold(
          body: BlocBuilder<ReceipeDetailsController, ReceipeDetailsState>(
              builder: (context, receipeDetailsState) {
            if (receipeDetailsState.reciepe == null) {
              return const Center(
                child: CustomCircularLoader(),
              );
            }
            final receipe = receipeDetailsState.reciepe!;

            return Column(
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
                    receipe.name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 20.0,
                      height: 30 / 20,
                      color: blackVariantColor,
                    ),
                  ),
                ),
                const Gap(10.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ExpansionTile(
                    title: Text(
                      AppText.ingredients,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        height: 24 / 16,
                        color: blackVariantColor,
                      ),
                    ),
                    children: [
                      const Gap(15.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 17.0,
                        ),
                        child: Column(
                          children: receipe.ingredients
                              .map(
                                (ingredient) => Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 15.0,
                                  ),
                                  child: _DisplayIngredients(
                                    ingredient: ingredient.name,
                                    quantity: ingredient.quantity ?? '',
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        );
      }),
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
