import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/analytics/analytics_event.dart';
import 'package:recipe_ai/analytics/analytics_repository.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
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

/// Static placeholder data for fields the [Receipe] model does not expose
/// yet. See the properties listed at the bottom of this file's related PR
/// description for what should eventually be added to the domain model.
const _placeholderDietaryTags = ['Végé', 'Diabétique'];
const _placeholderDifficulty = 'Facile';
const _placeholderBaseServings = 2;
const _placeholderProteins = '28g';
const _placeholderCarbs = '42g';
const _placeholderFats = '19g';
const _placeholderDidYouKnowFact =
    "Le riz arborio doit son onctuosité à sa forte teneur en amidon, "
    "libéré lentement pendant la cuisson.";

class _RecipeImageContainer extends StatelessWidget {
  const _RecipeImageContainer({required this.child, required this.image});

  final Widget? child;
  final DecorationImage? image;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.42,
      decoration: BoxDecoration(
        color: const Color(0xffFFCE80),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
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

  int _servings = _placeholderBaseServings;
  List<bool>? _checkedIngredients;

  void _ensureCheckedIngredients(int ingredientsCount) {
    if (_checkedIngredients == null ||
        _checkedIngredients!.length != ingredientsCount) {
      _checkedIngredients = List<bool>.filled(ingredientsCount, false);
    }
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
      child: Builder(
        builder: (context) {
          return Scaffold(
            body: BlocBuilder<ReceipeDetailsController, ReceipeDetailsState>(
              builder: (context, receipeDetailsState) {
                if (receipeDetailsState.reciepe == null) {
                  return const Center(child: CustomCircularLoader());
                }
                final receipe = receipeDetailsState.reciepe!;
                _ensureCheckedIngredients(receipe.ingredients.length);

                return Stack(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: BlocProvider(
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
                          },
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.42 - 24,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _DietaryTagsRow(tags: _placeholderDietaryTags),
                                    const Gap(12.0),
                                    Text(
                                      receipe.name,
                                      style: TextStyle(
                                        fontFamily: poppinsFontFamily,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 22.0,
                                        color: newNeutralBlackColor,
                                      ),
                                    ),
                                    const Gap(10.0),
                                    _RecipeInfoRow(
                                      averageTime: receipe.averageTime,
                                      calories: getOnlyNumber(
                                        receipe.totalCalories,
                                      ),
                                      difficulty: _placeholderDifficulty,
                                    ),
                                  ],
                                ),
                              ),
                              const Gap(24.0),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: _PortionsSelector(
                                  label: appTexts.portions,
                                  servings: _servings,
                                  onDecrement: _servings > 1
                                      ? () => setState(() => _servings--)
                                      : null,
                                  onIncrement: () =>
                                      setState(() => _servings++),
                                ),
                              ),
                              const Gap(24.0),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: _MacrosRow(
                                  calories: getOnlyNumber(
                                    receipe.totalCalories,
                                  ),
                                  proteins: _placeholderProteins,
                                  proteinsLabel: appTexts.proteins,
                                  carbs: _placeholderCarbs,
                                  carbsLabel: appTexts.carbs,
                                  fats: _placeholderFats,
                                  fatsLabel: appTexts.fats,
                                ),
                              ),
                              const Gap(30.0),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      appTexts.ingredients,
                                      style: TextStyle(
                                        fontFamily: poppinsFontFamily,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 17,
                                        color: newNeutralBlackColor,
                                      ),
                                    ),
                                    const Gap(15.0),
                                    ...receipe.ingredients.asMap().entries.map<
                                      Widget
                                    >(
                                      (entry) => _DisplayIngredients(
                                        ingredient: entry.value.name,
                                        quantity: entry.value.quantity ?? '',
                                        checked:
                                            _checkedIngredients![entry.key],
                                        onChanged: (value) => setState(() {
                                          _checkedIngredients![entry.key] =
                                              value;
                                        }),
                                      ),
                                    ),
                                    const Gap(10.0),
                                    _AddToShoppingListButton(
                                      label: appTexts.addToShoppingList,
                                      onPressed: () {},
                                    ),
                                    const Gap(30.0),
                                    _StepsSection(
                                      title: appTexts.preparation,
                                      steps: receipe.steps,
                                    ),
                                    const Gap(20.0),
                                    _DidYouKnowCard(
                                      title: appTexts.didYouKnow,
                                      fact: _placeholderDidYouKnowFact,
                                    ),
                                    const Gap(24.0),
                                    _PrimaryActionButton(
                                      label: appTexts.startCookingMode,
                                      onPressed: () {},
                                    ),
                                    const Gap(16.0),
                                    Center(
                                      child: TextButton(
                                        onPressed: () {},
                                        child: Text(
                                          appTexts.markAsCooked,
                                          style: TextStyle(
                                            fontFamily: poppinsFontFamily,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            color: greenPrimaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Gap(30.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 50,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _CircleIconButton(
                              onTap: () => context.pop(),
                              child: SvgPicture.asset(
                                'assets/images/arrowLeft.svg',
                                height: 18,
                                colorFilter: const ColorFilter.mode(
                                  Color(0xff0A2533),
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            _CircleIconButton(
                              onTap: null,
                              padding: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: RecipeIconFavorite(
                                  receipe: receipeDetailsState.userReceipeV2!,
                                  size: 18,
                                  colorFilter: null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: 70,
                          top: 55,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            final uid = di<IAuthUserService>()
                                .currentUser!
                                .uid
                                .value;
                            final language = di<TranslationController>()
                                .currentLanguageEnum;
                            final recipeName = language == AppLanguage.fr
                                ? receipeDetailsState
                                      .userReceipeV2!
                                      .receipeFr
                                      .name
                                : receipeDetailsState
                                      .userReceipeV2!
                                      .receipeEn
                                      .name;

                            final urlToShare =
                                'https://eateasy.live/home/recipe-details/${language.name}/$uid/${recipeName.replaceAll(' ', '_')}';
                            log(urlToShare);
                            Clipboard.setData(
                              ClipboardData(text: urlToShare),
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  appTexts.shareLink,
                                  style: TextStyle(
                                    fontFamily: poppinsFontFamily,
                                  ),
                                ),
                              ),
                            );
                          },
                          child: SvgPicture.asset(
                            'assets/icon/shareIcon.svg',
                            height: 24,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.onTap,
    required this.child,
    this.padding = 10,
  });

  final VoidCallback? onTap;
  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 44,
        height: 44,
        padding: EdgeInsets.all(padding),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 2),
              blurRadius: 8,
              color: Color.fromRGBO(0, 0, 0, 0.15),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _DietaryTagsRow extends StatelessWidget {
  const _DietaryTagsRow({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.asMap().entries.map((entry) {
        final isEven = entry.key.isEven;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isEven
                ? badgeGreenBackgroundColor
                : badgeOrangeBackgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            entry.value,
            style: TextStyle(
              fontFamily: poppinsFontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: isEven ? greenPrimaryColor : orangeVariantColor,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _RecipeInfoRow extends StatelessWidget {
  const _RecipeInfoRow({
    required this.averageTime,
    required this.calories,
    required this.difficulty,
  });

  final String averageTime;
  final String calories;
  final String difficulty;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontFamily: poppinsFontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: neutralGrey2Color,
    );

    return Row(
      children: [
        Text(averageTime, style: style),
        const Gap(8),
        Text('•', style: style),
        const Gap(8),
        Text('$calories kcal', style: style),
        const Gap(8),
        Text('•', style: style),
        const Gap(8),
        Text(difficulty, style: style),
      ],
    );
  }
}

class _PortionsSelector extends StatelessWidget {
  const _PortionsSelector({
    required this.label,
    required this.servings,
    required this.onDecrement,
    required this.onIncrement,
  });

  final String label;
  final int servings;
  final VoidCallback? onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: poppinsFontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: newNeutralBlackColor,
          ),
        ),
        const Gap(20),
        _RoundIconButton(
          onTap: onDecrement,
          icon: Icons.remove,
          background: Colors.white,
          iconColor: neutralGrey2Color,
          bordered: true,
        ),
        const Gap(14),
        Text(
          '$servings',
          style: TextStyle(
            fontFamily: poppinsFontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: newNeutralBlackColor,
          ),
        ),
        const Gap(14),
        _RoundIconButton(
          onTap: onIncrement,
          icon: Icons.add,
          background: greenPrimaryColor,
          iconColor: Colors.white,
          bordered: false,
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.onTap,
    required this.icon,
    required this.background,
    required this.iconColor,
    required this.bordered,
  });

  final VoidCallback? onTap;
  final IconData icon;
  final Color background;
  final Color iconColor;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          border: bordered
              ? Border.all(color: const Color(0xffE3EBEC))
              : null,
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
    );
  }
}

class _MacrosRow extends StatelessWidget {
  const _MacrosRow({
    required this.calories,
    required this.proteins,
    required this.proteinsLabel,
    required this.carbs,
    required this.carbsLabel,
    required this.fats,
    required this.fatsLabel,
  });

  final String calories;
  final String proteins;
  final String proteinsLabel;
  final String carbs;
  final String carbsLabel;
  final String fats;
  final String fatsLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MacroItem(
            value: calories,
            unit: 'kcal',
            barColor: orangeVariantColor,
          ),
        ),
        Expanded(
          child: _MacroItem(
            value: proteins,
            unit: proteinsLabel,
            barColor: greenPrimaryColor,
          ),
        ),
        Expanded(
          child: _MacroItem(
            value: carbs,
            unit: carbsLabel,
            barColor: yellowBrandColor,
          ),
        ),
        Expanded(
          child: _MacroItem(
            value: fats,
            unit: fatsLabel,
            barColor: fatBarColor,
          ),
        ),
      ],
    );
  }
}

class _MacroItem extends StatelessWidget {
  const _MacroItem({
    required this.value,
    required this.unit,
    required this.barColor,
  });

  final String value;
  final String unit;
  final Color barColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: RichText(
              maxLines: 1,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontFamily: poppinsFontFamily,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: newNeutralBlackColor,
                    ),
                  ),
                  TextSpan(
                    text: ' $unit',
                    style: TextStyle(
                      fontFamily: poppinsFontFamily,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: neutralGrey2Color,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Gap(8),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(4),
            ),
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
    required this.checked,
    required this.onChanged,
  });

  final String ingredient;
  final String quantity;
  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!checked),
      borderRadius: BorderRadius.circular(10),
      child: Container(
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
              color: Color.fromRGBO(6, 51, 54, 0.1),
            ),
          ],
        ),
        child: Row(
          children: [
            _IngredientCheckbox(checked: checked),
            const Gap(12),
            Flexible(
              child: Text(
                ingredient,
                style: TextStyle(
                  fontFamily: poppinsFontFamily,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  height: 24 / 16,
                  color: const Color(0xff1E1E1E),
                ),
              ),
            ),
            const Spacer(),
            Text(
              quantity,
              style: TextStyle(
                fontFamily: poppinsFontFamily,
                fontWeight: FontWeight.w400,
                fontSize: 14,
                height: 21 / 14,
                color: const Color(0xff1E1E1E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IngredientCheckbox extends StatelessWidget {
  const _IngredientCheckbox({required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: checked ? greenPrimaryColor : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: checked ? greenPrimaryColor : const Color(0xffD9E2E6),
          width: 1.5,
        ),
      ),
      child: checked
          ? const Icon(Icons.check, size: 16, color: Colors.white)
          : null,
    );
  }
}

class _AddToShoppingListButton extends StatelessWidget {
  const _AddToShoppingListButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: greenPrimaryColor),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        icon: const Icon(Icons.add, color: greenPrimaryColor, size: 18),
        label: Text(
          label,
          style: const TextStyle(
            fontFamily: poppinsFontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: greenPrimaryColor,
          ),
        ),
      ),
    );
  }
}

class _StepsSection extends StatelessWidget {
  const _StepsSection({required this.title, required this.steps});

  final String title;
  final List<ReceipeStep> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: poppinsFontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: newNeutralBlackColor,
          ),
        ),
        const Gap(15.0),
        ...steps.map((step) {
          final index = steps.indexOf(step) + 1;
          return _StepView(index: index, step: step);
        }),
      ],
    );
  }
}

class _StepView extends StatelessWidget {
  const _StepView({required this.index, required this.step});
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
            color: Color.fromRGBO(6, 51, 54, 0.1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: greenPrimaryColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      fontFamily: poppinsFontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const Gap(16),
              Expanded(
                child: Text(
                  step.description,
                  style: TextStyle(
                    fontFamily: poppinsFontFamily,
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
              padding: const EdgeInsets.only(top: 18.0),
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
                    style: TextStyle(
                      fontFamily: poppinsFontFamily,
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

class _DidYouKnowCard extends StatelessWidget {
  const _DidYouKnowCard({required this.title, required this.fact});

  final String title;
  final String fact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tipBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: tipIconBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb,
              size: 18,
              color: Colors.white,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: poppinsFontFamily,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: tipIconBackgroundColor,
                  ),
                ),
                const Gap(6),
                Text(
                  fact,
                  style: TextStyle(
                    fontFamily: poppinsFontFamily,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    height: 21 / 14,
                    color: newNeutralBlackColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: greenPrimaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: poppinsFontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
