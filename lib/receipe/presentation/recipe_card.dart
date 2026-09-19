import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/auth/application/auth_user_service.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/home/presentation/recipe_image_loader.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';
import 'package:recipe_ai/home/presentation/recipe_metadata_card_loader.dart';
import 'package:recipe_ai/receipe/presentation/recipe_tag_style.dart';
import 'package:recipe_ai/user_account/domain/repositories/user_account_meta_data_repository.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/user_preferences/presentation/components/custom_circular_loader.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';
import 'package:recipe_ai/utils/function_caller.dart';
import 'package:recipe_ai/utils/functions.dart';

const _cardHeight = 190.0;
const _cardRadius = 20.0;

/// Recipe card of the redesign (matches the 06-accueil.html mockup): a full
/// bleed picture with the recipe name and its meta line laid over a dark
/// gradient.
class RecipeCard extends StatelessWidget {
  const RecipeCard({
    super.key,
    required this.receipe,
    this.redirectionPath = '/home/recipe-details',
    this.titleRecipeSize,
  });

  final UserRecipeV2 receipe;
  final String redirectionPath;
  final double? titleRecipeSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(redirectionPath, extra: {'receipe': receipe}),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_cardRadius),
        child: SizedBox(
          height: _cardHeight,
          width: double.infinity,
          // The image loader is shared by the picture and the overlay: a card
          // without a picture gets the lighter ink gradient of the mockup.
          child: BlocProvider(
            create: (context) => RecipeImageLoader(
              di<FunctionsCaller>(),
              receipe.receipeEn.name,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                const _RecipeCardImage(),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: BlocProvider(
                    create: (context) => RecipeMetadataCardLoader(
                      receipe,
                      di<IUserAccountMetaDataRepository>(),
                      di<IAuthUserService>(),
                    ),
                    child: BlocBuilder<RecipeMetadataCardLoader, Receipe>(
                      builder: (context, translatedReceipe) =>
                          BlocBuilder<RecipeImageLoader, RecipeImageState>(
                            builder: (context, imageState) =>
                                _RecipeCardOverlay(
                                  receipe: translatedReceipe,
                                  titleRecipeSize: titleRecipeSize,
                                  hasPhoto:
                                      imageState is RecipeImageLoaded &&
                                      imageState.url != null,
                                ),
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecipeCardImage extends StatelessWidget {
  const _RecipeCardImage();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecipeImageLoader, RecipeImageState>(
      builder: (context, recipeImageState) {
        if (recipeImageState is RecipeImageLoading) {
          return const RecipeNoPhotoBackground(child: CustomCircularLoader());
        }

        final imageUrl = (recipeImageState as RecipeImageLoaded).url;

        if (imageUrl == null) {
          return const RecipeNoPhotoBackground();
        }

        return CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          progressIndicatorBuilder: (context, url, progress) =>
              RecipeNoPhotoBackground(
                child: CustomCircularLoader(value: progress.progress),
              ),
          errorWidget: (context, url, error) => const RecipeNoPhotoBackground(),
        );
      },
    );
  }
}

/// Background of a recipe without a picture (23c mockup): beige, two faint
/// rings and a green cutlery medallion. [child] (a loader) replaces the
/// medallion while the picture is being fetched.
class RecipeNoPhotoBackground extends StatelessWidget {
  const RecipeNoPhotoBackground({
    super.key,
    this.child,
    // On the cards, the medallion sits in the upper part, clear of the title.
    this.alignment = const Alignment(0, -0.45),
  });

  final Widget? child;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 82 px on the home card, smaller in the favorites grid.
        final medallionSize = (constraints.maxHeight * 0.43).clamp(40.0, 82.0);

        return DecoratedBox(
          decoration: const BoxDecoration(
            color: recipeCardNoPhotoBackgroundColor,
          ),
          child: CustomPaint(
            painter: const _NoPhotoRingsPainter(),
            child: Align(
              alignment: alignment,
              child: child ?? _CutleryMedallion(size: medallionSize),
            ),
          ),
        );
      },
    );
  }
}

class _CutleryMedallion extends StatelessWidget {
  const _CutleryMedallion({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: recipeLoaderGreenColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: recipeLoaderGreenColor.withValues(alpha: 0.35),
            blurRadius: size * 0.3,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: Icon(
        Icons.restaurant_rounded,
        color: Colors.white,
        size: size * 0.44,
      ),
    );
  }
}

/// The two faint rings of the no-photo card: a large one bleeding out of the
/// top left corner, a smaller one on the right edge.
class _NoPhotoRingsPainter extends CustomPainter {
  const _NoPhotoRingsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = recipeCardNoPhotoRingColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.035;

    canvas.drawCircle(
      Offset(size.width * 0.18, size.height * 0.23),
      size.height * 0.35,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.87, size.height * 0.46),
      size.height * 0.31,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _NoPhotoRingsPainter oldDelegate) => false;
}

class _RecipeCardOverlay extends StatelessWidget {
  const _RecipeCardOverlay({
    required this.receipe,
    required this.hasPhoto,
    this.titleRecipeSize,
  });

  final Receipe receipe;
  final bool hasPhoto;
  final double? titleRecipeSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: hasPhoto
              ? [
                  recipeCardOverlayColor.withValues(alpha: 0.9),
                  recipeCardOverlayColor.withValues(alpha: 0.0),
                ]
              : [
                  recipeLoaderInkColor.withValues(alpha: 0.95),
                  recipeLoaderInkColor.withValues(alpha: 0.0),
                ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            receipe.name,
            style: TextStyle(
              fontFamily: robotoSlabFontFamily,
              fontWeight: FontWeight.w600,
              fontSize: titleRecipeSize ?? 15,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 3),
          _RecipeCardMetaLine(receipe: receipe),
        ],
      ),
    );
  }
}

/// The `Végé · Diabétique · 25 min · 480 kcal` line, tags first and colored by
/// their family.
class _RecipeCardMetaLine extends StatelessWidget {
  const _RecipeCardMetaLine({required this.receipe});

  final Receipe receipe;

  static const _neutralColor = Color(0xD9FFFFFF); // white at 85%

  Color _tagColor(String tag) {
    switch (classifyRecipeTag(tag)) {
      case RecipeTagKind.green:
        return recipeCardTagGreenColor;
      case RecipeTagKind.amber:
        return recipeCardTagAmberColor;
      case RecipeTagKind.salmon:
        return recipeCardTagSalmonColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTexts = di<TranslationController>().currentLanguage;
    final calories = getOnlyNumber(receipe.totalCalories);

    final segments = <(String, Color)>[
      for (final tag in receipe.tags) (tag, _tagColor(tag)),
      if (receipe.averageTime.isNotEmpty) (receipe.averageTime, _neutralColor),
      if (calories.isNotEmpty)
        ('$calories ${appTexts.recipeDetailsKcal}', _neutralColor),
    ];

    final children = <Widget>[];
    for (final (index, segment) in segments.indexed) {
      if (index > 0) {
        children.add(const _MetaSegment(label: '·', color: _neutralColor));
      }
      children.add(_MetaSegment(label: segment.$1, color: segment.$2));
    }

    return Wrap(
      spacing: 6,
      runSpacing: 2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}

class _MetaSegment extends StatelessWidget {
  const _MetaSegment({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: robotoFontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 10.5,
        color: color,
      ),
    );
  }
}
