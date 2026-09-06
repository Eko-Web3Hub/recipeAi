import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:recipe_ai/home/presentation/translated_text.dart';
import 'package:recipe_ai/l10n/app_localizations.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

/// Floating navigation bar of the redesign (matches the 06-accueil.html
/// mockup): a white pill split in five equal slots, the middle one left empty
/// for the [ChefFab] docked on top of it.
class FancyBottomBar extends StatelessWidget {
  const FancyBottomBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  /// Exactly four items: two on the left of the FAB, two on its right.
  final List<BarItemData> items;
  final int currentIndex;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    assert(items.length == 4, 'The bar is laid out around four items');

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(29),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2E22331F),
                blurRadius: 26,
                spreadRadius: -6,
                offset: Offset(0, 10),
              ),
              BoxShadow(
                color: Color(0x0F22331F),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(29),
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: [
                for (var index = 0; index < 2; index++)
                  Expanded(
                    child: _BarItem(
                      data: items[index],
                      selected: index == currentIndex,
                      onTap: () => onTap(index),
                    ),
                  ),
                // Slot left empty for the docked FAB.
                const Spacer(),
                for (var index = 2; index < 4; index++)
                  Expanded(
                    child: _BarItem(
                      data: items[index],
                      selected: index == currentIndex,
                      onTap: () => onTap(index),
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

class BarItemData {
  const BarItemData({required this.asset, required this.labelSelector});

  /// Path of the SVG glyph, tinted by the bar.
  final String asset;
  final String Function(AppLocalizations lang) labelSelector;
}

class _BarItem extends StatelessWidget {
  const _BarItem({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final BarItemData data;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // The selection is animated by hand rather than with an ink splash: a
    // splash would paint a square that fights with the rounded pill.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: selected ? 1 : 0),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          builder: (context, progress, child) {
            final color = Color.lerp(
              bottomNavInactiveColor,
              bottomNavActiveColor,
              progress,
            )!;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: recipeLoaderMintColor.withValues(alpha: progress),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    data.asset,
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                  ),
                  const SizedBox(height: 2),
                  TranslatedText(
                    textSelector: data.labelSelector,
                    style: TextStyle(
                      fontFamily: robotoFontFamily,
                      fontWeight: FontWeight.w600,
                      fontSize: 10.5,
                      color: color,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Round action button docked on the top edge of the [FancyBottomBar].
class ChefFab extends StatelessWidget {
  const ChefFab({
    super.key,
    required this.onPressed,
    this.iconAsset = 'assets/icon/nav_chef_hat.svg',
  });

  final VoidCallback onPressed;
  final String iconAsset;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bottomNavFabColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: const [
            BoxShadow(
              color: Color(0x80D88A14),
              blurRadius: 18,
              spreadRadius: -4,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: Center(
              child: SvgPicture.asset(
                iconAsset,
                width: 26,
                height: 26,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
