import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/application/user_personnal_info_service.dart';
import 'package:recipe_ai/auth/domain/model/user_personnal_info.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/home/presentation/home_screen_controller.dart';
import 'package:recipe_ai/home/presentation/receipe_item_controller.dart';
import 'package:recipe_ai/receipe/application/retrieve_receipe_from_api_one_time_per_day_usecase.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository.dart';
import 'package:recipe_ai/user_preferences/presentation/components/custom_progress.dart';
import 'package:recipe_ai/utils/app_text.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/functions.dart';
import 'package:recipe_ai/utils/styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeScreenController(
        di<RetrieveReceipeFromApiOneTimePerDayUsecase>(),
      ),
      child: Builder(builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: horizontalScreenPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(20.0),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _HeadLeftSection(),
                    _HeadRightSection(),
                  ],
                ),
                const Gap(15),
                Text(
                  AppText.quickRecipes,
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
                      )));
                    }

                    if (homeScreenState is HomeScreenStateError) {
                      return Expanded(child: Text(homeScreenState.message));
                    }

                    if (homeScreenState is HomeScreenStateLoaded) {
                      return Expanded(
                          child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 20, top: 15),
                        itemBuilder: (context, index) {
                          return BlocProvider(
                            create: (context) => ReceipeItemController(
                              homeScreenState.receipes[index],
                              di<IUserReceipeRepository>(),
                              di<IAuthUserService>(),
                              index,
                            ),
                            child: BlocBuilder<ReceipeItemController,
                                ReceipeItemStatus>(
                              builder: (context, state) {
                                return ReceipeItem(
                                  receipe: homeScreenState.receipes[index],
                                  isSaved: state == ReceipeItemStatus.saved,
                                  onTap: () {
                                    context
                                        .read<ReceipeItemController>()
                                        .saveReceipe();
                                  },
                                );
                              },
                            ),
                          );
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
        );
      }),
    );
  }
}

class ReceipeItem extends StatefulWidget {
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
  State<ReceipeItem> createState() => _ReceipeItemState();
}

class _ReceipeItemState extends State<ReceipeItem> {
  bool _saved = false;

  @override
  void initState() {
    _saved = widget.isSaved;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        '/home/recipe-details',
        extra: {
          'receipe': widget.receipe,
        },
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFFEBEBEB),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: Image.asset(
                "assets/images/recipe_image.jpeg",
                width: double.infinity,
                fit: BoxFit.cover,
                height: 140,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.receipe.name,
                          style: smallTextStyle,
                        ),
                      ),
                      Text(
                        widget.receipe.totalCalories,
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
                            "Avg Time",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400,
                              color: neutralGreyColor,
                              fontSize: 11,
                              height: 16.5 / 11,
                            ),
                          ),
                          Text(
                            widget.receipe.averageTime,
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
                          onTap: () {
                            setState(() {
                              _saved = !_saved;
                            });
                            widget.onTap();
                          },
                          child: SvgPicture.asset(_saved
                              ? "assets/images/favorite.svg"
                              : "assets/images/favorite_outlined.svg"))
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _HeadLeftSection extends StatelessWidget {
  const _HeadLeftSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _UserTitleWidget(),
        const Gap(5.0),
        Text(
          AppText.letCreateMealToday,
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
    return StreamBuilder<UserPersonnalInfo?>(
      stream: di<IUserPersonnalInfoService>().watch(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Text(
            '${AppText.hello} ${capitalizeFirtLetter(snapshot.data!.name)}',
            style: Theme.of(context).textTheme.displayLarge,
          );
        }

        return Text(
          '${AppText.hello} !',
          style: Theme.of(context).textTheme.displayLarge,
        );
      },
    );
  }
}

class _HeadRightSection extends StatelessWidget {
  const _HeadRightSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(
          12.0,
        ),
      ),
    );
  }
}
