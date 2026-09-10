import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/analytics/analytics_repository.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/auth/application/user_personnal_info_service.dart';
import 'package:recipe_ai/auth/domain/model/user_personnal_info.dart';
import 'package:recipe_ai/auth/presentation/components/custom_snack_bar.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/home/presentation/app_update.dart';
import 'package:recipe_ai/home/presentation/home_screen_controller.dart';
import 'package:recipe_ai/home/presentation/receipe_item_controller.dart';
import 'package:recipe_ai/home/presentation/recipe_image_loader.dart';
import 'package:recipe_ai/home/presentation/recipe_metadata_card_loader.dart';
import 'package:recipe_ai/home/presentation/translated_text.dart';
import 'package:recipe_ai/l10n/app_localizations.dart';
import 'package:recipe_ai/receipe/presentation/recipe_card.dart';
import 'package:recipe_ai/notification/presentation/notification_user_controller.dart';
import 'package:recipe_ai/receipe/application/user_recipe_service.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/user_account/application/user_account_metadata_service.dart';
import 'package:recipe_ai/user_account/domain/repositories/user_account_meta_data_repository.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/user_preferences/presentation/components/custom_circular_loader.dart';
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
    final notificationUserController = context
        .read<NotificationUserController>();
    final homeScreenController = context.read<HomeScreenController>();

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      homeScreenController.reload();

      await di<TranslationController>().saveLanguageWhenNeeded();
      await di<IUserAccountMetaDataService>().saveRecentLoginDate(
        DateTime.now(),
      );
      await showAppUpdatePopup(context);
      notificationUserController.requestPermission(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    // The bottom navigation bar floats above the body ([Scaffold.extendBody]),
    // so the last card needs room to scroll past it.
    final bottomInset =
        _bottomNavBarSpacing + MediaQuery.of(context).padding.bottom;

    return BlocListener<HomeScreenController, HomeScreenState>(
      listener: (context, homeScreenState) {
        if (homeScreenState is HomeScreenStateRequiresLogin) {
          showSnackBar(
            context,
            di<TranslationController>()
                .currentLanguage
                .sessionExpiredLoginAgain,
            isError: true,
          );
          context.go('/onboarding/start/login');
        }
      },
      child: ColoredBox(
        color: recipeLoaderCreamColor,
        child: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: Theme.of(context).primaryColor,
            onRefresh: () async {
              context.read<HomeScreenController>().regenerateUserReceipe();

              return Future.delayed(const Duration(seconds: 1));
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: _HomeHeader(),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 6),
                    child: _QuickActions(),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 2),
                    child: _ForYouTodayHeader(),
                  ),
                ),
                _HomeRecipes(bottomInset: bottomInset),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Height reserved under the content for the floating bottom navigation bar.
const _bottomNavBarSpacing = 96.0;

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserPersonnalInfo?>(
      stream: di<IUserPersonnalInfoService>().watch(),
      builder: (context, snapshot) {
        final name = snapshot.data?.name;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _HomeGreeting(name: name)),
            const SizedBox(width: 12),
            _HomeAvatar(name: name),
          ],
        );
      },
    );
  }
}

class _HomeGreeting extends StatelessWidget {
  const _HomeGreeting({required this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    final userName = name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TranslatedText(
          textSelector: (lang) => userName == null || userName.isEmpty
              ? '${lang.hello},'
              : '${lang.hello} ${capitalizeFirtLetter(userName)},',
          style: TextStyle(
            fontFamily: robotoFontFamily,
            fontWeight: FontWeight.w500,
            fontSize: 12.5,
            color: recipeLoaderInkColor.withValues(alpha: 0.55),
          ),
        ),
        const Gap(2),
        TranslatedText(
          textSelector: (lang) => lang.homeCookWhatToday,
          style: const TextStyle(
            fontFamily: robotoSlabFontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 21,
            height: 1.25,
            color: recipeLoaderInkColor,
          ),
        ),
      ],
    );
  }
}

class _HomeAvatar extends StatelessWidget {
  const _HomeAvatar({required this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    final userName = name;

    return GestureDetector(
      // TODO(navigation): plug the profile redirection once decided.
      onTap: () => _showComingSoon(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: recipeLoaderGreenColor,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: userName == null || userName.isEmpty
            ? null
            : Text(
                userName[0].toUpperCase(),
                style: const TextStyle(
                  fontFamily: robotoFontFamily,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

void _showComingSoon(BuildContext context) {
  final appTexts = di<TranslationController>().currentLanguage;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        appTexts.recipeDetailsComingSoon,
        style: const TextStyle(fontFamily: robotoFontFamily),
      ),
    ),
  );
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    // TODO(navigation): plug the three redirections once decided.
    // [IntrinsicHeight] keeps the three tiles the same height even when one
    // label wraps on two lines.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _QuickActionTile(
              background: recipeLoaderMintColor,
              iconBackground: recipeLoaderGreenColor,
              icon: const _ShoppingListGlyph(),
              labelSelector: (lang) => lang.homeQuickActionList,
              onTap: () => _showComingSoon(context),
            ),
          ),
          const Gap(10),
          Expanded(
            child: _QuickActionTile(
              background: homeFridgeTileBackgroundColor,
              iconBackground: homeFridgeIconBackgroundColor,
              icon: const _FridgeGlyph(),
              labelSelector: (lang) => lang.homeQuickActionFridge,
              onTap: () => _showComingSoon(context),
            ),
          ),
          const Gap(10),
          Expanded(
            child: _QuickActionTile(
              background: homePhotoTileBackgroundColor,
              iconBackground: homePhotoIconBackgroundColor,
              icon: const _CameraGlyph(),
              labelSelector: (lang) => lang.homeQuickActionPhoto,
              onTap: () => _showComingSoon(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.background,
    required this.iconBackground,
    required this.icon,
    required this.labelSelector,
    required this.onTap,
  });

  final Color background;
  final Color iconBackground;
  final Widget icon;
  final String Function(AppLocalizations lang) labelSelector;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);

    return Material(
      color: background,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: icon,
              ),
              const Gap(9),
              TranslatedText(
                textSelector: labelSelector,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: robotoFontFamily,
                  fontWeight: FontWeight.w600,
                  fontSize: 10.5,
                  color: recipeLoaderInkColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Three stacked bars, the "Ma liste" glyph of the mockup.
class _ShoppingListGlyph extends StatelessWidget {
  const _ShoppingListGlyph();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (index) => Padding(
          padding: EdgeInsets.only(top: index == 0 ? 0 : 3),
          child: const SizedBox(
            width: 15,
            height: 2,
            child: ColoredBox(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// Outlined fridge with its door line, the "Mon frigo" glyph of the mockup.
class _FridgeGlyph extends StatelessWidget {
  const _FridgeGlyph();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 25,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const Positioned(
            top: 10,
            left: 0,
            right: 0,
            height: 2,
            child: ColoredBox(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

/// Outlined camera, the "Photo" glyph of the mockup.
class _CameraGlyph extends StatelessWidget {
  const _CameraGlyph();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 16,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Positioned(
            top: 4,
            left: 7,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ForYouTodayHeader extends StatelessWidget {
  const _ForYouTodayHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TranslatedText(
          textSelector: (lang) => lang.homeForYouToday,
          style: const TextStyle(
            fontFamily: robotoSlabFontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: recipeLoaderInkColor,
          ),
        ),
        const Gap(3),
        // TODO(preferences): append the user's dietary preferences
        // ("· Diabétique, SOPK" in the mockup) once they are exposed as a
        // readable list.
        TranslatedText(
          textSelector: (lang) => lang.homeForYouTodaySubtitle,
          style: TextStyle(
            fontFamily: robotoFontFamily,
            fontWeight: FontWeight.w400,
            fontSize: 11.5,
            color: recipeLoaderInkColor.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}

class _HomeRecipes extends StatelessWidget {
  const _HomeRecipes({required this.bottomInset});

  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return BlocBuilder<HomeScreenController, HomeScreenState>(
      builder: (context, homeScreenState) {
        if (homeScreenState is HomeScreenStateLoading) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(child: CustomCircularLoader()),
            ),
          );
        }

        if (homeScreenState is HomeScreenStateError) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
              child: Text(
                homeScreenState.message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: robotoFontFamily,
                  fontSize: 12.5,
                  color: recipeLoaderInkColor.withValues(alpha: 0.55),
                ),
              ),
            ),
          );
        }

        if (homeScreenState is! HomeScreenStateLoaded) {
          return const SliverToBoxAdapter(child: SizedBox());
        }

        if (homeScreenState.receipes.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
              child: Text(
                appTexts.emptyReceipes,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: robotoFontFamily,
                  fontSize: 12.5,
                  color: recipeLoaderInkColor.withValues(alpha: 0.55),
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: EdgeInsets.fromLTRB(20, 14, 20, 8 + bottomInset),
          sliver: SliverList.separated(
            itemCount: homeScreenState.receipes.length,
            separatorBuilder: (context, index) => const Gap(16),
            itemBuilder: (context, index) => RecipeCard(
              key: ValueKey(homeScreenState.receipes[index].id),
              receipe: homeScreenState.receipes[index],
            ),
          ),
        );
      },
    );
  }
}

class ReceipeItem extends StatelessWidget {
  final UserRecipeV2 receipe;

  final String redirectionPath;
  const ReceipeItem({
    super.key,
    required this.receipe,
    this.redirectionPath = '/home/recipe-details',
  });

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return GestureDetector(
      onTap: () => context.push(redirectionPath, extra: {'receipe': receipe}),
      child: Container(
        height: 219,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Stack(
          children: [
            BlocProvider(
              create: (context) => RecipeImageLoader(
                di<FunctionsCaller>(),
                receipe.receipeEn.name,
              ),
              child: Builder(
                builder: (context) {
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
                          child: Image.asset(
                            'assets/images/recipePlaceHolder.png',
                          ),
                        );
                      }

                      return ClipRRect(
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          progressIndicatorBuilder: (context, url, progress) =>
                              _ImageRecipeContainer(
                                child: CustomCircularLoader(
                                  value: progress.progress,
                                ),
                              ),
                          errorWidget: (context, url, error) =>
                              _ImageRecipeContainer(
                                child: Image.asset(
                                  'assets/images/recipePlaceHolder.png',
                                ),
                              ),
                          imageBuilder: (context, imageProvider) => ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                            child: Image(
                              image: imageProvider,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              height: 219,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    child: BlocProvider(
                      create: (context) => RecipeMetadataCardLoader(
                        receipe,
                        di<IUserAccountMetaDataRepository>(),
                        di<IAuthUserService>(),
                      ),
                      child: BlocBuilder<RecipeMetadataCardLoader, Receipe>(
                        builder: (context, receipeTranslateState) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      receipeTranslateState.name,
                                      style: smallTextStyle.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${getOnlyNumber(receipeTranslateState.totalCalories)} cal*',
                                    style: TextStyle(
                                      fontFamily: poppinsFontFamily,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      height: 14.52 / 12,
                                      color: secondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        appTexts.averageTime,
                                        style: TextStyle(
                                          fontFamily: poppinsFontFamily,
                                          fontWeight: FontWeight.w400,
                                          color: greenPrimaryColor,
                                          fontSize: 11,
                                          height: 16.5 / 11,
                                        ),
                                      ),
                                      Text(
                                        receipeTranslateState.averageTime,
                                        style: TextStyle(
                                          fontFamily: poppinsFontFamily,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                          color: secondaryColor,
                                          height: 16.5 / 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                  RecipeIconFavorite(
                                    receipe: receipe,
                                    colorFilter: recipeCardColorFilter,
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecipeIconFavorite extends StatelessWidget {
  const RecipeIconFavorite({
    super.key,
    required this.receipe,
    this.fillFavoriteIcon = 'assets/images/favorite.svg',
    this.outlinedFavoriteIcon = 'assets/images/favorite_outlined.svg',
    this.padding = 16,
    this.size,
    required this.colorFilter,
  });

  final UserRecipeV2 receipe;
  final String fillFavoriteIcon;
  final String outlinedFavoriteIcon;
  final double padding;
  final double? size;
  final ColorFilter? colorFilter;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReceipeItemController(
        receipe,
        di<IUserRecipeService>(),
        di<IAnalyticsRepository>(),
      ),
      child: Builder(
        builder: (context) {
          return BlocListener<ReceipeItemController, ReceipeItemState>(
            listener: (context, state) {
              if (state is ReceipeItemStateError) {
                showSnackBar(context, state.message, isError: true);
              }
            },
            child: BlocBuilder<ReceipeItemController, ReceipeItemState>(
              builder: (context, recipeItemSaved) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: context.read<ReceipeItemController>().toggleFavorite,
                  child: Container(
                    //padding: EdgeInsets.all(16),
                    color: Colors.transparent,
                    child: SvgPicture.asset(
                      recipeItemSaved is ReceipeItemStateSaved
                          ? fillFavoriteIcon
                          : outlinedFavoriteIcon,
                      height: size,
                      fit: BoxFit.cover,
                      colorFilter: colorFilter,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ImageRecipeContainer extends StatelessWidget {
  const _ImageRecipeContainer({required this.child});

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
        color: Color(0xffFFCE80),
      ),
      child: Center(child: child),
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

class ExpandingCircleDemo extends StatefulWidget {
  @override
  _ExpandingCircleDemoState createState() => _ExpandingCircleDemoState();
}

class _ExpandingCircleDemoState extends State<ExpandingCircleDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxRadius = size.height * 1.2;

    return ClipPath(
      clipper: CircleClipper(_animation.value * maxRadius),
      child: Container(color: Colors.blueAccent),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class CircleClipper extends CustomClipper<Path> {
  final double radius;
  CircleClipper(this.radius);

  @override
  Path getClip(Size size) {
    final center = Offset(size.width - 60, size.height - 60);
    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(CircleClipper oldClipper) => radius != oldClipper.radius;
}
