import 'package:flutter/material.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/user_preferences/domain/model/onboarding_step.dart';
import 'package:recipe_ai/utils/colors.dart';

/// Turns the catalogue data (translations, icon names, hex colors) into what
/// the widgets draw.

extension LocalizedStringDisplay on LocalizedString {
  /// The text in the current app language.
  String get text => resolve(di<TranslationController>().currentLanguageEnum);
}

/// Icons an option can use, by the name written in Firestore. Flutter drops
/// the icons the code never references from the release build, so an icon
/// can only be picked from this list; adding one needs a release.
const onboardingIcons = <String, IconData>{
  // Activity.
  'chair_outlined': Icons.chair_outlined,
  'directions_walk': Icons.directions_walk,
  'directions_bike': Icons.directions_bike,
  'directions_run': Icons.directions_run,
  'local_fire_department_outlined': Icons.local_fire_department_outlined,
  'fitness_center': Icons.fitness_center,
  'pool': Icons.pool,
  'sports_soccer': Icons.sports_soccer,
  'self_improvement': Icons.self_improvement,
  'hiking': Icons.hiking,
  // Goals and health.
  'trending_up': Icons.trending_up,
  'trending_down': Icons.trending_down,
  'favorite_border': Icons.favorite_border,
  'water_drop_outlined': Icons.water_drop_outlined,
  'monitor_heart_outlined': Icons.monitor_heart_outlined,
  'bedtime_outlined': Icons.bedtime_outlined,
  'bolt': Icons.bolt,
  'spa_outlined': Icons.spa_outlined,
  'psychology_outlined': Icons.psychology_outlined,
  'balance': Icons.balance,
  'child_care': Icons.child_care,
  'pregnant_woman': Icons.pregnant_woman,
  // Food.
  'restaurant': Icons.restaurant,
  'eco_outlined': Icons.eco_outlined,
  'grass': Icons.grass,
  'set_meal_outlined': Icons.set_meal_outlined,
  'egg_outlined': Icons.egg_outlined,
  'bakery_dining_outlined': Icons.bakery_dining_outlined,
  'local_drink_outlined': Icons.local_drink_outlined,
  'no_food_outlined': Icons.no_food_outlined,
  'timer_outlined': Icons.timer_outlined,
  'savings_outlined': Icons.savings_outlined,
};

const _fallbackIcon = Icons.circle_outlined;

IconData onboardingIconOf(String? name) =>
    onboardingIcons[name] ?? _fallbackIcon;

/// `#RRGGBB` (or `#AARRGGBB`), the brand green when missing or malformed.
Color onboardingColorOf(String? hex) {
  final digits = hex?.replaceFirst('#', '').trim() ?? '';
  final value = int.tryParse(digits, radix: 16);
  if (value == null) return recipeLoaderGreenColor;
  if (digits.length == 6) return Color(0xFF000000 | value);
  if (digits.length == 8) return Color(value);
  return recipeLoaderGreenColor;
}
