import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/application/user_personnal_info_service.dart';
import 'package:recipe_ai/auth/domain/model/user_personnal_info.dart';
import 'package:recipe_ai/auth/presentation/components/custom_snack_bar.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/home/presentation/home_screen_controller.dart';
import 'package:recipe_ai/home/presentation/receipe_item_controller.dart';
import 'package:recipe_ai/home/presentation/recipe_image_loader.dart';
import 'package:recipe_ai/home/presentation/recipe_metadata_card_loader.dart';
import 'package:recipe_ai/receipe/application/user_recipe_translate_service.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/user_preferences/presentation/components/custom_circular_loader.dart';
import 'package:recipe_ai/user_preferences/presentation/components/custom_progress.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/function_caller.dart';
import 'package:recipe_ai/utils/functions.dart';
import 'package:recipe_ai/utils/styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      context.read<HomeScreenController>().reload();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return Builder(builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: horizontalScreenPadding,
          ),
          child: RefreshIndicator(
            color: Theme.of(context).primaryColor,
            backgroundColor: Colors.white,
            onRefresh: () async {
              context.read<HomeScreenController>().regenerateUserReceipe();

              return Future.delayed(
                const Duration(seconds: 1),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(20.0),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _HeadLeftSection(),
                  ],
                ),
                const Gap(15),
                Text(
                  appTexts.quickRecipes,
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge
                      ?.copyWith(fontSize: 17),
                ),
                BlocBuilder<HomeScreenController, HomeScreenState>(
                  builder: (context, homeScreenState) {
                    if (homeScreenState is HomeScreenStateLoading) {
                      /// A modifier. Afficher une liste de carte avec un shimmer effect
                      return const Expanded(
                        child: Center(
                          child: CustomProgress(
                            color: Colors.black,
                          ),
                        ),
                      );
                    }

                    if (homeScreenState is HomeScreenStateError) {
                      return Expanded(child: Text(homeScreenState.message));
                    }

                    if (homeScreenState is HomeScreenStateLoaded) {
                      return Expanded(
                          child: homeScreenState.receipes.isEmpty
                              ? Center(
                                  child: Text(
                                    appTexts.emptyReceipes,
                                    style: smallTextStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.only(
                                      bottom: 20, top: 15),
                                  itemBuilder: (context, index) {
                                    return BlocProvider(
                                        create: (context) =>
                                            ReceipeItemController(
                                              homeScreenState.receipes[index],
                                              di<IUserReceipeRepository>(),
                                              di<IAuthUserService>(),
                                            ),
                                        child: BlocListener<
                                            ReceipeItemController,
                                            ReceipeItemState>(
                                          listener: (context, state) {
                                            if (state
                                                is ReceipeItemStateError) {
                                              showSnackBar(
                                                  context, state.message,
                                                  isError: true);
                                            }
                                          },
                                          child: BlocBuilder<
                                              ReceipeItemController,
                                              ReceipeItemState>(
                                            builder: (context, state) {
                                              return ReceipeItem(
                                                receipe: homeScreenState
                                                    .receipes[index],
                                                isSaved: state
                                                    is ReceipeItemStateSaved,
                                                onTap: () {
                                                  if (state
                                                      is ReceipeItemStateSaved) {
                                                    context
                                                        .read<
                                                            ReceipeItemController>()
                                                        .removeReceipe();
                                                  } else {
                                                    context
                                                        .read<
                                                            ReceipeItemController>()
                                                        .saveReceipe();
                                                  }
                                                },
                                              );
                                            },
                                          ),
                                        ));
                                  },
                                  itemCount: homeScreenState.receipes.length,
                                ));
                    }

                    return const SizedBox();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class ReceipeItem extends StatelessWidget {
  final Receipe receipe;
  final bool isSaved;
  final void Function() onTap;
  const ReceipeItem({
    super.key,
    required this.receipe,
    required this.isSaved,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return GestureDetector(
      onTap: () => context.push(
        '/home/recipe-details',
        extra: {
          'receipe': receipe,
        },
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Colors.white),
        child: Column(
          children: [
            BlocProvider(
              create: (context) => RecipeImageLoader(
                di<FunctionsCaller>(),
                receipe.name,
              ),
              child: Builder(builder: (context) {
                return BlocBuilder<RecipeImageLoader, RecipeImageState>(
                  builder: (context, imageLoaderState) {
                    if (imageLoaderState is RecipeImageLoading) {
                      return const _ImageRecipeContainer(
                        child: CustomCircularLoader(),
                      );
                    }
                    final imageUrl =
                        (imageLoaderState as RecipeImageLoaded).url;

                    if (imageUrl == null) {
                      return _ImageRecipeContainer(
                        child: SvgPicture.asset(
                          "assets/images/receipe_placeholder_icon.svg",
                          width: 90,
                          height: 90,
                        ),
                      );
                    }

                    return CachedNetworkImage(
                      imageUrl: imageUrl,
                      progressIndicatorBuilder: (context, url, progress) =>
                          _ImageRecipeContainer(
                              child: CustomCircularLoader(
                        value: progress.progress,
                      )),
                      errorWidget: (context, url, error) =>
                          _ImageRecipeContainer(
                        child: SvgPicture.asset(
                          "assets/images/receipe_placeholder_icon.svg",
                          width: 90,
                          height: 90,
                        ),
                      ),
                      imageBuilder: (context, imageProvider) => ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                        child: Image(
                          image: imageProvider,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          height: 140,
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: BlocProvider(
                create: (context) => RecipeMetadataCardLoader(
                  receipe,
                  di<UserRecipeTranslateService>(),
                ),
                child: BlocBuilder<RecipeMetadataCardLoader, Receipe>(
                    builder: (context, receipeTranslateState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              receipeTranslateState.name,
                              style: smallTextStyle,
                            ),
                          ),
                          Text(
                            '${_getOnlyNumber(receipe.totalCalories)} cal*',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              height: 14.52 / 12,
                              color: Colors.black,
                            ),
                          )
                        ],
                      ),
                      const Gap(8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appTexts.averageTime,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w400,
                                  color: neutralGreyColor,
                                  fontSize: 11,
                                  height: 16.5 / 11,
                                ),
                              ),
                              Text(
                                receipe.averageTime,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                  color: neutralBlackColor,
                                  height: 16.5 / 11,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: onTap,
                            child: SvgPicture.asset(
                              isSaved
                                  ? "assets/images/favorite.svg"
                                  : "assets/images/favorite_outlined.svg",
                            ),
                          )
                        ],
                      ),
                    ],
                  );
                }),
              ),
            )
          ],
        ),
      ),
    );
  }
}

String _getOnlyNumber(String text) {
  return text.replaceAll(RegExp(r'[^0-9]'), '');
}

class _ImageRecipeContainer extends StatelessWidget {
  const _ImageRecipeContainer({
    required this.child,
  });

  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        color: greyVariantColor,
      ),
      child: Center(child: child),
    );
  }
}

class _HeadLeftSection extends StatelessWidget {
  const _HeadLeftSection();

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _UserTitleWidget(),
        const Gap(5.0),
        Text(
          appTexts.letCreateMealToday,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}

class _UserTitleWidget extends StatelessWidget {
  const _UserTitleWidget();

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return StreamBuilder<UserPersonnalInfo?>(
      stream: di<IUserPersonnalInfoService>().watch(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Text(
            '${appTexts.hello} ${capitalizeFirtLetter(snapshot.data!.name)}',
            style: Theme.of(context).textTheme.displayLarge,
          );
        }

        return Text(
          '${appTexts.hello} !',
          style: Theme.of(context).textTheme.displayLarge,
        );
      },
    );
  }
}

class UserFirstNameCharOnCapitalCase extends StatelessWidget {
  const UserFirstNameCharOnCapitalCase({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserPersonnalInfo?>(
      stream: di<IUserPersonnalInfoService>().watch(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Text(
            snapshot.data!.name[0].toUpperCase(),
            style: Theme.of(context).textTheme.displayLarge,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
