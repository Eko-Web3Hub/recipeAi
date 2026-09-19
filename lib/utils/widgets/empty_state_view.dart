import 'package:flutter/material.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

/// Empty state of the redesigned screens: a cream disc holding [icon], a
/// Roboto Slab title, a muted subtitle and an optional [child] (chips,
/// button) below.
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconSize = 70,
    this.child,
  });

  final Widget icon;
  final String title;
  final String subtitle;
  final double iconSize;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: const BoxDecoration(
                color: recipeLoaderCreamColor,
                shape: BoxShape.circle,
              ),
              child: Center(child: icon),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: robotoSlabFontFamily,
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: recipeLoaderInkColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: robotoFontFamily,
                fontWeight: FontWeight.w400,
                fontSize: 11,
                height: 1.5,
                color: recipeLoaderInkColor.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 20),
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}
