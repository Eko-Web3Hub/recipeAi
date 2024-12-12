import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/step.dart';
import 'package:recipe_ai/receipe/presentation/receipe_details_controller.dart';
import 'package:recipe_ai/user_preferences/presentation/components/custom_circular_loader.dart';
import 'package:recipe_ai/user_preferences/presentation/user_preference_question_widget.dart';
import 'package:recipe_ai/utils/app_text.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

class ReceipeDetailsView extends StatelessWidget {
  const ReceipeDetailsView({
    super.key,
    required this.receipeId,
  });

  final EntityId receipeId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReceipeDetailsController(
        receipeId,
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

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
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
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 40.0,
                          left: 20.0,
                        ),
                        child: InkWell(
                          onTap: () => context.pop(),
                          child:
                              SvgPicture.asset('assets/images/arrowLeft.svg'),
                        ),
                      ),
                    ],
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
                        style: normalTextStyle,
                      ),
                      children: [
                        const Gap(15.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
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
                  const SizedBox(height: 38),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 38.0),
                    child: _StepsSection(
                      receipe.steps,
                    ),
                  ),
                  const Gap(51.0),
                ],
              ),
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CheckBoxOption(
          option: ingredient,
          onChanged: (isSelected) {},
        ),
        Text(
          quantity,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            height: 21 / 14,
            color: const Color(0xff1E1E1E),
          ),
        ),
      ],
    );
  }
}

class _StepsSection extends StatelessWidget {
  const _StepsSection(this.steps);

  final List<ReceipeStep> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(15.0),
        Text(
          AppText.steps,
          style: normalTextStyle,
        ),
        const Gap(15.0),
        ...steps.map(
          (step) {
            final index = steps.indexOf(step) + 1;
            return _StepView(
              index: index,
              step: step,
            );
          },
        ),
      ],
    );
  }
}

class _StepView extends StatelessWidget {
  const _StepView({
    required this.index,
    required this.step,
  });
  final int index;
  final ReceipeStep step;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      color: Colors.white,
      surfaceTintColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 15.0,
          right: 28.0,
          left: 26.0,
          bottom: 20.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step $index',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                height: 24 / 16,
                color: Colors.black,
              ),
            ),
            const Gap(2.0),
            Text(
              step.description,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                height: 21 / 14,
                color: Colors.black,
              ),
            ),
            Visibility(
              visible: step.duration != null,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 18.0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 38,
                      height: 29,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: const Color(0xff1976D2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: SvgPicture.asset('assets/images/timer.svg'),
                      ),
                    ),
                    const Gap(8.0),
                    Text(
                      '${step.duration}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        height: 21 / 14,
                        color: const Color(0xff1E1E1E),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
