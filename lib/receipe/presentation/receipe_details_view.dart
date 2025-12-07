import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/analytics/analytics_event.dart';
import 'package:recipe_ai/analytics/analytics_repository.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/presentation/components/custom_toggle_button.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/home/presentation/home_screen.dart';
import 'package:recipe_ai/home/presentation/recipe_image_loader.dart';
import 'package:recipe_ai/receipe/domain/model/step.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository_v2.dart';
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
        color: const Color(0xffFFCE80),
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

/// ReceipeDetailsView
/// Contains the details of a receipe
/// The receipe is passed or loaded using the receipe id
class ReceipeDetailsView extends StatefulWidget {
  const ReceipeDetailsView({
    super.key,
    required this.receipeId,
    required this.receipe,
    required this.appLanguage,
    required this.userSharingUid,
  });

  final EntityId? receipeId;
  final UserReceipeV2? receipe;
  final AppLanguage? appLanguage;
  final EntityId? userSharingUid;

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

  int _toggleBtnIndex = 0;
  int get toggleBtnIndex => _toggleBtnIndex;
  set toggleBtnIndex(int value) {
    setState(() {
      _toggleBtnIndex = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;
    return BlocProvider(
      create: (_) => widget.receipeId != null
          ? ReceipeDetailsController(
              widget.receipeId,
              widget.appLanguage,
              widget.userSharingUid,
              null,
              di<IAuthUserService>(),
              di<IUserAccountMetaDataRepository>(),
              di<IUserReceipeRepositoryV2>(),
            )
          : ReceipeDetailsController.fromReceipe(
              widget.receipe!,
              di<IAuthUserService>(),
              di<IUserAccountMetaDataRepository>(),
              di<IUserReceipeRepositoryV2>(),
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

            return Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: BlocProvider(
                    create: (context) => RecipeImageLoader(
                      di<FunctionsCaller>(),
                      receipe.name,
                    ),
                    child: Builder(builder: (context) {
                      return BlocBuilder<RecipeImageLoader, RecipeImageState>(
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
                            return _RecipeImageContainer(
                              image: null,
                              child: Image.asset(
                                'assets/images/recipePlaceHolder.png',
                              ),
                            );
                          }

                          return CachedNetworkImage(
                            imageUrl: receipeImageUrl,
                            errorWidget: (context, url, error) =>
                                _RecipeImageContainer(
                              image: null,
                              child: Image.asset(
                                'assets/images/recipePlaceHolder.png',
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
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: const EdgeInsets.only(top: 250),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        )),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [],
                          ),
                          Center(
                            child: Container(
                              width: 50,
                              height: 5,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3EBEC),
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                          const Gap(20.0),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              receipe.name,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 20.0,
                                color: newNeutralBlackColor,
                              ),
                            ),
                          ),
                          const Gap(20.0),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                _NutrientItem(
                                    asset: 'plant', title: '65g carbs'),
                                const Gap(30),
                                _NutrientItem(
                                    asset: 'proteins', title: '25g protein'),
                              ],
                            ),
                          ),
                          const Gap(30.0),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                _NutrientItem(
                                    asset: 'calories', title: '120 Kcal'),
                                const Gap(45),
                                _NutrientItem(asset: 'fats', title: '91g fats'),
                              ],
                            ),
                          ),
                          const Gap(30.0),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: CustomToggleButton(
                              leftContent: appTexts.ingredients,
                              rightContent: appTexts.steps,
                              onToggle: (index) {
                                toggleBtnIndex = index;
                              },
                            ),
                          ),
                          const Gap(30.0),
                          if (toggleBtnIndex == 0) ...[
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        appTexts.ingredients,
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 17),
                                      ),
                                      TextButton(
                                          onPressed: () {},
                                          child: Text(
                                            'Add all to list',
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14,
                                                color: greenPrimaryColor),
                                          ))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '${receipe.ingredients.length} Items',
                                        style: GoogleFonts.poppins(
                                            color: const Color(0xFF748189),
                                            fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: receipe.ingredients.length,
                                    itemBuilder: (context, index) {
                                      final ingredient =
                                          receipe.ingredients[index];
                                      return _DisplayIngredients(
                                          ingredient: ingredient.name,
                                          quantity: ingredient.quantity ?? '');
                                    },
                                  )
                                ],
                              ),
                            )
                          ] else ...[
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: _StepsSection(
                                receipe.steps,
                              ),
                            ),
                          ],
                          // Padding(
                          //   padding:
                          //       const EdgeInsets.symmetric(horizontal: 24.0),
                          //   child: ExpansionTile(
                          //     initiallyExpanded: true,
                          //     title: TranslatedText(
                          //         textSelector: (lang) => lang.ingredients,
                          //         style: normalTextStyle),
                          //     children: [
                          //       const Gap(15.0),
                          //       Padding(
                          //         padding: const EdgeInsets.symmetric(
                          //           horizontal: 16.0,
                          //         ),
                          //         child: Column(
                          //           children: receipe.ingredients
                          //               .map(
                          //                 (ingredient) => Padding(
                          //                   padding: const EdgeInsets.only(
                          //                     bottom: 15.0,
                          //                   ),
                          //                   child: _DisplayIngredients(
                          //                     ingredient: ingredient.name,
                          //                     quantity:
                          //                         ingredient.quantity ?? '',
                          //                   ),
                          //                 ),
                          //               )
                          //               .toList(),
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),

                          const Gap(51.0),
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () => context.pop(),
                          child: SvgPicture.asset(
                            'assets/images/arrowLeft.svg',
                            height: 30,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcATop,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: RecipeIconFavorite(
                                receipe: receipeDetailsState.userReceipeV2!,
                                outlinedFavoriteIcon:
                                    'assets/icon/icon_favorite_white.svg',
                                size: 25,
                                colorFilter: recipeCardColorFilter,
                              ),
                            ),
                            const Gap(14),
                            GestureDetector(
                              onTap: () {
                                final uid = di<IAuthUserService>()
                                    .currentUser!
                                    .uid
                                    .value;
                                final language = di<TranslationController>()
                                    .currentLanguageEnum;
                                final recipeName = language == AppLanguage.fr
                                    ? receipeDetailsState
                                        .userReceipeV2!.receipeFr.name
                                    : receipeDetailsState
                                        .userReceipeV2!.receipeEn.name;

                                final urlToShare =
                                    'https://eateasy.live/home/recipe-details/${language.name}/$uid/${recipeName.replaceAll(' ', '_')}';
                                log(urlToShare);
                                Clipboard.setData(
                                  ClipboardData(
                                    text: urlToShare,
                                  ),
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      appTexts.shareLink,
                                      style: GoogleFonts.poppins(),
                                    ),
                                  ),
                                );
                              },
                              child: SvgPicture.asset(
                                'assets/icon/shareIcon.svg',
                                height: 30,
                                fit: BoxFit.cover,
                              ),
                            ),
                            //  const Gap(25),
                          ],
                        ),
                      ],
                    ),
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

class _NutrientItem extends StatelessWidget {
  final String asset;
  final String title;
  const _NutrientItem({required this.asset, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: neutralGrey4Color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: SvgPicture.asset('assets/icon/$asset.svg'),
          ),
        ),
        const Gap(17),
        Text(
          title,
          style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: newNeutralBlackColor),
        )
      ],
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 2),
                blurRadius: 16,
                spreadRadius: 0,
                color: Color.fromRGBO(6, 51, 54, 0.1))
          ]),
      child: Row(
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
      ),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              appTexts.steps,
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: newNeutralBlackColor),
            ),
            Text(
              '${steps.length} ${appTexts.steps}',
              style: GoogleFonts.poppins(
                color: const Color(0xFF748189),
                fontSize: 14,
              ),
            )
          ],
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
    return Container(
      padding: const EdgeInsets.only(
        top: 16.0,
        right: 16.0,
        left: 16.0,
        bottom: 16.0,
      ),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 2),
                blurRadius: 16,
                spreadRadius: 0,
                color: Color.fromRGBO(6, 51, 54, 0.1))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TranslatedText(
          //   textSelector: (lang) => '${lang.step} $index',
          //   style: GoogleFonts.poppins(
          //     fontWeight: FontWeight.w600,
          //     fontSize: 16,
          //     height: 24 / 16,
          //     color: Colors.black,
          //   ),
          // ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                    color: neutralGrey4Color,
                    borderRadius: BorderRadius.circular(6)),
                child: Center(
                  child: Text(
                    '$index',
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: greenPrimaryColor),
                  ),
                ),
              ),
              const Gap(16),
              Expanded(
                child: Text(
                  step.description,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    height: 21 / 14,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
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
                      color: greenPrimaryColor,
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
    );
  }
}
