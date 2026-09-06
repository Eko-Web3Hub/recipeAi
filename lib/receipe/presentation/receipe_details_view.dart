import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/analytics/analytics_event.dart';
import 'package:recipe_ai/analytics/analytics_repository.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/home/presentation/home_screen.dart';
import 'package:recipe_ai/home/presentation/recipe_image_loader.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/step.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository_v2.dart';
import 'package:recipe_ai/receipe/presentation/food_fact_card.dart';
import 'package:recipe_ai/receipe/presentation/receipe_details_controller.dart';
import 'package:recipe_ai/user_account/domain/repositories/user_account_meta_data_repository.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/user_preferences/presentation/components/custom_circular_loader.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/function_caller.dart';

const _heroHeight = 270.0;

class _RecipeImageContainer extends StatelessWidget {
  const _RecipeImageContainer({required this.child, required this.image});

  final Widget? child;
  final DecorationImage? image;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: _heroHeight,
      decoration: BoxDecoration(color: const Color(0xFFDFDBD2), image: image),
      child: Center(child: child),
    );
  }
}

/// ReceipeDetailsView
/// Contains the details of a receipe
/// The receipe is passed or loaded using the receipe id
class RecipeDetailsView extends StatefulWidget {
  const RecipeDetailsView({
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
  State<RecipeDetailsView> createState() => _RecipeDetailsViewState();
}

class _RecipeDetailsViewState extends State<RecipeDetailsView> {
  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      di<IAnalyticsRepository>().logEvent(RecipeSeenEvent());
    });
  }

  int _portions = 2;
  final Set<int> _checkedIngredientIndices = {};

  void _showComingSoon(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          appTexts.recipeDetailsComingSoon,
          style: TextStyle(fontFamily: robotoFontFamily),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: BlocBuilder<ReceipeDetailsController, ReceipeDetailsState>(
              builder: (context, receipeDetailsState) {
                if (receipeDetailsState.reciepe == null) {
                  return const Center(child: CustomCircularLoader());
                }
                final receipe = receipeDetailsState.reciepe!;
                final appTexts = di<TranslationController>().currentLanguage;

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
                            child: Builder(
                              builder: (context) {
                                return BlocBuilder<
                                  RecipeImageLoader,
                                  RecipeImageState
                                >(
                                  builder: (context, recipeImageState) {
                                    if (recipeImageState
                                        is RecipeImageLoading) {
                                      return const _RecipeImageContainer(
                                        image: null,
                                        child: CustomCircularLoader(),
                                      );
                                    }

                                    final receipeImageUrl =
                                        (recipeImageState as RecipeImageLoaded)
                                            .url;

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
                                            child: CustomCircularLoader(
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
                              },
                            ),
                          ),
                          Positioned(
                            top: MediaQuery.of(context).padding.top + 18,
                            left: 18,
                            child: _HeroOverlayButton(
                              onTap: () => context.pop(),
                              child: SvgPicture.asset(
                                'assets/images/arrowLeft.svg',
                                height: 15,
                                colorFilter: const ColorFilter.mode(
                                  recipeLoaderInkColor,
                                  BlendMode.srcATop,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: MediaQuery.of(context).padding.top + 18,
                            right: 18,
                            child: _HeroOverlayButton(
                              child: RecipeIconFavorite(
                                receipe: receipeDetailsState.userReceipeV2!,
                                outlinedFavoriteIcon:
                                    'assets/icon/icon_favorite_white.svg',
                                size: 16,
                                colorFilter: const ColorFilter.mode(
                                  recipeDetailAmberTagTextColor,
                                  BlendMode.srcATop,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (receipe.tags.isNotEmpty) ...[
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: receipe.tags
                                    .map((tag) => _TagChip(label: tag))
                                    .toList(),
                              ),
                              const SizedBox(height: 8),
                            ],
                            Text(
                              receipe.name,
                              style: const TextStyle(
                                fontFamily: robotoSlabFontFamily,
                                fontWeight: FontWeight.w600,
                                fontSize: 21,
                                height: 1.3,
                                color: recipeLoaderInkColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _MetaRow(receipe: receipe),
                            const SizedBox(height: 16),
                            _PortionsStepper(
                              portions: _portions,
                              onChanged: (value) =>
                                  setState(() => _portions = value),
                            ),
                            if (receipe.proteinGrams != null &&
                                receipe.carbsGrams != null &&
                                receipe.lipidsGrams != null) ...[
                              const SizedBox(height: 16),
                              _MacrosGrid(receipe: receipe),
                            ],
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
                        child: Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0x1522331F),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Text(
                          appTexts.ingredients,
                          style: const TextStyle(
                            fontFamily: robotoSlabFontFamily,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: recipeLoaderInkColor,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                        child: Column(
                          children: List.generate(receipe.ingredients.length, (
                            index,
                          ) {
                            final ingredient = receipe.ingredients[index];
                            return _IngredientRow(
                              name: ingredient.name,
                              quantity: ingredient.quantity ?? '',
                              checked: _checkedIngredientIndices.contains(
                                index,
                              ),
                              onTap: () => setState(() {
                                if (!_checkedIngredientIndices.remove(index)) {
                                  _checkedIngredientIndices.add(index);
                                }
                              }),
                            );
                          }),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                        child: _OutlinedActionButton(
                          icon: Icons.add,
                          label: appTexts.recipeDetailsAddToShoppingList,
                          onTap: () => _showComingSoon(context),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                        child: Text(
                          appTexts.recipeDetailsPreparationTitle,
                          style: const TextStyle(
                            fontFamily: robotoSlabFontFamily,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: recipeLoaderInkColor,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
                        child: Column(
                          children: List.generate(receipe.steps.length, (
                            index,
                          ) {
                            return Padding(
                              padding: EdgeInsets.only(
                                top: index == 0 ? 0 : 14,
                              ),
                              child: _PreparationStepRow(
                                index: index + 1,
                                step: receipe.steps[index],
                              ),
                            );
                          }),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 170),
                        child: Column(
                          children: [
                            if (receipe.foodFact case final foodFact?)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 40.0),
                                child: FoodFactCard(foodFact: foodFact),
                              ),

                            _PrimaryActionButton(
                              label: appTexts.recipeDetailsCookMode,
                              onTap: () => context.push(
                                '/cook-mode',
                                extra: {
                                  'receipe': receipe,
                                  'userReceipeV2':
                                      receipeDetailsState.userReceipeV2,
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                            _GhostActionButton(
                              label: appTexts.recipeDetailsMarkAsCooked,
                              onTap: () => _showComingSoon(context),
                            ),
                          ],
                        ),
                      ),
                    ],
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

class _HeroOverlayButton extends StatelessWidget {
  const _HeroOverlayButton({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isAmber =
        label.toLowerCase().contains('diab') ||
        label.toLowerCase().contains('diet');
    final background = isAmber
        ? recipeDetailAmberTagBackgroundColor
        : recipeLoaderMintColor;
    final foreground = isAmber
        ? recipeDetailAmberTagTextColor
        : recipeLoaderGreenColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: robotoFontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 10,
          color: foreground,
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.receipe});

  final Receipe receipe;

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;
    final segments = [
      receipe.averageTime,
      '${getOnlyNumber(receipe.totalCalories)} ${appTexts.recipeDetailsKcal}',
      if (receipe.difficulty != null) receipe.difficulty!,
    ];

    final children = <Widget>[];
    for (var i = 0; i < segments.length; i++) {
      if (i > 0) {
        children.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: _MetaDot(),
          ),
        );
      }
      children.add(
        Text(
          segments[i],
          style: TextStyle(
            fontFamily: robotoFontFamily,
            fontWeight: FontWeight.w500,
            fontSize: 11,
            color: recipeLoaderInkColor.withValues(alpha: 0.55),
          ),
        ),
      );
    }

    return Row(children: children);
  }
}

class _MetaDot extends StatelessWidget {
  const _MetaDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: 3,
      decoration: BoxDecoration(
        color: recipeLoaderInkColor.withValues(alpha: 0.35),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _PortionsStepper extends StatelessWidget {
  const _PortionsStepper({required this.portions, required this.onChanged});

  final int portions;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;

    return Row(
      children: [
        Text(
          appTexts.recipeDetailsPortions,
          style: TextStyle(
            fontFamily: robotoFontFamily,
            fontWeight: FontWeight.w500,
            fontSize: 12.5,
            color: recipeLoaderInkColor.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: recipeLoaderCreamColor,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            children: [
              _StepperButton(
                symbol: '−',
                background: Colors.white,
                foreground: recipeLoaderInkColor,
                onTap: portions > 1 ? () => onChanged(portions - 1) : null,
              ),
              SizedBox(
                width: 24,
                child: Text(
                  '$portions',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: robotoFontFamily,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: recipeLoaderInkColor,
                  ),
                ),
              ),
              _StepperButton(
                symbol: '+',
                background: recipeLoaderGreenColor,
                foreground: Colors.white,
                onTap: () => onChanged(portions + 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.symbol,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String symbol;
  final Color background;
  final Color foreground;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: onTap == null ? background.withValues(alpha: 0.5) : background,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            symbol,
            style: TextStyle(
              fontFamily: robotoFontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: foreground,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

double? _leadingNumber(String? raw) {
  if (raw == null) return null;
  final match = RegExp(r'[0-9]+([.,][0-9]+)?').firstMatch(raw);
  if (match == null) return null;
  return double.tryParse(match.group(0)!.replaceAll(',', '.'));
}

class _MacrosGrid extends StatelessWidget {
  const _MacrosGrid({required this.receipe});

  final Receipe receipe;

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;
    final calories = _leadingNumber(receipe.totalCalories);
    final protein = _leadingNumber(receipe.proteinGrams);
    final carbs = _leadingNumber(receipe.carbsGrams);
    final lipids = _leadingNumber(receipe.lipidsGrams);

    return Row(
      children: [
        Expanded(
          child: _MacroColumn(
            value: getOnlyNumber(receipe.totalCalories),
            label: appTexts.recipeDetailsKcal,
            fraction: calories == null ? 0 : calories / 2000,
            barColor: recipeDetailCaloriesBarColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MacroColumn(
            value: receipe.proteinGrams!,
            label: appTexts.recipeDetailsProtein,
            fraction: protein == null ? 0 : protein / 50,
            barColor: recipeLoaderGreenColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MacroColumn(
            value: receipe.carbsGrams!,
            label: appTexts.recipeDetailsCarbs,
            fraction: carbs == null ? 0 : carbs / 260,
            barColor: recipeDetailCarbsBarColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MacroColumn(
            value: receipe.lipidsGrams!,
            label: appTexts.recipeDetailsLipids,
            fraction: lipids == null ? 0 : lipids / 70,
            barColor: recipeDetailLipidsBarColor,
          ),
        ),
      ],
    );
  }
}

class _MacroColumn extends StatelessWidget {
  const _MacroColumn({
    required this.value,
    required this.label,
    required this.fraction,
    required this.barColor,
  });

  final String value;
  final String label;
  final double fraction;
  final Color barColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontFamily: robotoFontFamily,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: recipeLoaderInkColor,
              ),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: robotoFontFamily,
                  fontWeight: FontWeight.w500,
                  fontSize: 9.5,
                  color: recipeLoaderInkColor.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Container(
            height: 5,
            color: recipeLoaderInkColor.withValues(alpha: 0.08),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: fraction.clamp(0.0, 1.0),
              child: DecoratedBox(decoration: BoxDecoration(color: barColor)),
            ),
          ),
        ),
      ],
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({
    required this.name,
    required this.quantity,
    required this.checked,
    required this.onTap,
  });

  final String name;
  final String quantity;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: recipeLoaderInkColor.withValues(alpha: 0.06),
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: checked ? recipeLoaderGreenColor : Colors.transparent,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: recipeLoaderGreenColor, width: 1.6),
              ),
              child: checked
                  ? const Icon(Icons.check, size: 11, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontFamily: robotoFontFamily,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: recipeLoaderInkColor,
                ),
              ),
            ),
            Text(
              quantity,
              style: TextStyle(
                fontFamily: robotoFontFamily,
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: recipeLoaderInkColor.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutlinedActionButton extends StatelessWidget {
  const _OutlinedActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: recipeLoaderGreenColor, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: recipeLoaderGreenColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: robotoFontFamily,
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
                color: recipeLoaderGreenColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreparationStepRow extends StatelessWidget {
  const _PreparationStepRow({required this.index, required this.step});

  final int index;
  final ReceipeStep step;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: recipeLoaderGreenColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$index',
              style: const TextStyle(
                fontFamily: robotoFontFamily,
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            step.description,
            style: const TextStyle(
              fontFamily: robotoFontFamily,
              fontWeight: FontWeight.w400,
              fontSize: 13,
              height: 1.5,
              color: recipeLoaderInkColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: recipeLoaderGreenColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: robotoFontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _GhostActionButton extends StatelessWidget {
  const _GhostActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 52,
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: robotoFontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
            color: recipeLoaderGreenColor,
          ),
        ),
      ),
    );
  }
}
