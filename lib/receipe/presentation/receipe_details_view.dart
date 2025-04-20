import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/analytics/analytics_event.dart';
import 'package:recipe_ai/analytics/analytics_repository.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/home/presentation/recipe_image_loader.dart';
import 'package:recipe_ai/home/presentation/translated_text.dart';
import 'package:recipe_ai/receipe/domain/model/step.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/receipe/presentation/receipe_details_controller.dart';
import 'package:recipe_ai/user_account/domain/repositories/user_account_meta_data_repository.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/user_preferences/presentation/components/custom_circular_loader.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/function_caller.dart';

class _RecipeImageContainer extends StatelessWidget {
  const _RecipeImageContainer({
    required this.child,
    required this.image,
  });

  final Widget? child;
  final DecorationImage? image;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: const Color(0xffEBEBEB),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        image: image,
      ),
      child: Center(child: child),
    );
  }
}

class _RecipeImagePlaceHolder extends StatelessWidget {
  const _RecipeImagePlaceHolder();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      "assets/images/receipe_placeholder_icon.svg",
      width: 90,
      height: 90,
    );
  }
}

/// ReceipeDetailsView
/// Contains the details of a receipe
/// The receipe is passed or loaded using the receipe id
class ReceipeDetailsView extends StatefulWidget {
  const ReceipeDetailsView({
    super.key,
    required this.receipeId,
    required this.receipe,
  });

  final EntityId? receipeId;
  final UserReceipeV2? receipe;

  @override
  State<ReceipeDetailsView> createState() => _ReceipeDetailsViewState();
}

class _ReceipeDetailsViewState extends State<ReceipeDetailsView> {
  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      di<IAnalyticsRepository>().logEvent(RecipeSeenEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => widget.receipeId != null
          ? ReceipeDetailsController(
              widget.receipeId,
              null,
              di<IAuthUserService>(),
              di<IUserAccountMetaDataRepository>(),
            )
          : ReceipeDetailsController.fromReceipe(
              widget.receipe!,
              di<IAuthUserService>(),
              di<IUserAccountMetaDataRepository>(),
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
                      BlocProvider(
                        create: (context) => RecipeImageLoader(
                          di<FunctionsCaller>(),
                          receipe.name,
                        ),
                        child: Builder(builder: (context) {
                          return BlocBuilder<RecipeImageLoader,
                              RecipeImageState>(
                            builder: (context, recipeImageState) {
                              if (recipeImageState is RecipeImageLoading) {
                                return const _RecipeImageContainer(
                                  image: null,
                                  child: CustomCircularLoader(),
                                );
                              }

                              final receipeImageUrl =
                                  (recipeImageState as RecipeImageLoaded).url;

                              if (receipeImageUrl == null) {
                                return const _RecipeImageContainer(
                                  image: null,
                                  child: _RecipeImagePlaceHolder(),
                                );
                              }

                              return CachedNetworkImage(
                                imageUrl: receipeImageUrl,
                                errorWidget: (context, url, error) =>
                                    _RecipeImageContainer(
                                  image: null,
                                  child: SvgPicture.asset(
                                    "assets/images/receipe_placeholder_icon.svg",
                                    width: 90,
                                    height: 90,
                                  ),
                                ),
                                progressIndicatorBuilder:
                                    (context, url, progress) => Center(
                                  child: CircularProgressIndicator(
                                    value: progress.progress,
                                  ),
                                ),
                                imageBuilder: (context, imageProvider) =>
                                    _RecipeImageContainer(
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                  child: null,
                                ),
                              );
                            },
                          );
                        }),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                          top: 50.0,
                          left: 20.0,
                        ),
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: InkWell(
                          onTap: () => context.pop(),
                          child: SvgPicture.asset(
                            'assets/images/arrowLeft.svg',
                            height: 30,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF858585),
                              BlendMode.srcATop,
                            ),
                          ),
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
                      initiallyExpanded: true,
                      title: TranslatedText(
                          textSelector: (lang) => lang.ingredients,
                          style: normalTextStyle),
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
        Flexible(
          child: Text(
            ingredient,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w400,
              fontSize: 16,
              height: 24 / 16,
              color: const Color(0xff1E1E1E),
            ),
          ),
        ),
        Flexible(
          child: Text(
            quantity,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              height: 21 / 14,
              color: const Color(0xff1E1E1E),
            ),
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
    final appTexts = di<TranslationController>().currentLanguage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(15.0),
        Text(
          appTexts.steps,
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
    return SizedBox(
      width: double.infinity,
      child: Card(
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
              TranslatedText(
                textSelector: (lang) => '${lang.step} $index',
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
                          color: const Color(0xff2254BF),
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
      ),
    );
  }
}
