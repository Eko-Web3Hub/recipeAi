import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/home/presentation/profile/profile_controller.dart';
import 'package:recipe_ai/home/presentation/setting/feedback_link.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';
import 'package:recipe_ai/user_preferences/presentation/dietary_summary.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

TextStyle settingHeadTitleStyle = TextStyle(
  fontFamily: poppinsFontFamily,
  fontSize: 14,
  fontWeight: FontWeight.w600,
  color: Colors.black,
);

/// Profile tab: who the user is, their diet, a few stats and the entries to
/// edit their preferences, notifications and to get help.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _controller = ProfileController.inject();

  /// The branch stays alive when another tab or a profile sub-screen is shown:
  /// its tickers are only muted. Coming back refreshes what may have changed
  /// meanwhile (a generated recipe, updated preferences).
  bool _wasVisible = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isVisible = TickerMode.of(context);
    if (isVisible && !_wasVisible) _controller.refresh();
    _wasVisible = isVisible;
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final translationController = di<TranslationController>();

    return BlocProvider.value(
      value: _controller,
      child: ColoredBox(
        color: recipeLoaderCreamColor,
        child: SafeArea(
          bottom: false,
          child: ListenableBuilder(
            listenable: translationController,
            builder: (context, _) {
              final appTexts = translationController.currentLanguage;

              return BlocBuilder<ProfileController, ProfileState>(
                builder: (context, state) {
                  return Stack(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                        child: Column(
                          children: [
                            _ProfileHeader(
                              name: state.name,
                              badges: state.preferences == null
                                  ? const []
                                  : dietarySummaryEntries(
                                      state.preferences!,
                                      state.steps,
                                      translationController.currentLanguageEnum,
                                    ),
                            ),
                            const Gap(18),
                            Row(
                              children: [
                                Expanded(
                                  child: _StatCard(
                                    value: state.generatedCount,
                                    label: appTexts.profileStatGenerated,
                                  ),
                                ),
                                const Gap(10),
                                Expanded(
                                  child: _StatCard(
                                    value: state.favoriteCount,
                                    label: appTexts.profileStatFavorites,
                                  ),
                                ),
                              ],
                            ),
                            const Gap(10),
                            _ProfileMenu(
                              items: [
                                _ProfileMenuItem(
                                  icon: Icons.restaurant_menu_rounded,
                                  label: appTexts.profileDietaryPreferences,
                                  onTap: () => context.push(
                                    '/profil-screen/update-user-preference',
                                  ),
                                ),
                                _ProfileMenuItem(
                                  icon: Icons.notifications_none_rounded,
                                  label: appTexts.notification,
                                  onTap: () => context.push(
                                    '/profil-screen/notifications',
                                  ),
                                ),
                                _ProfileMenuItem(
                                  icon: Icons.help_outline_rounded,
                                  label: appTexts.profileHelpContact,
                                  onTap: openFeedbackForm,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Positioned(
                        top: 12,
                        right: 0,
                        child: ProfilActionAppBar(),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Opens the settings: account, language and sign out.
class ProfilActionAppBar extends StatelessWidget {
  const ProfilActionAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: GestureDetector(
        onTap: () => context.push('/profil-screen/settings'),
        child: SvgPicture.asset('assets/images/settingProfilIcon.svg'),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.name, required this.badges});

  final String? name;
  final List<DietarySummaryEntry> badges;

  @override
  Widget build(BuildContext context) {
    final name = this.name;

    return Column(
      children: [
        Container(
          width: 78,
          height: 78,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: recipeLoaderGreenColor,
            shape: BoxShape.circle,
          ),
          child: name == null || name.isEmpty
              ? null
              : Text(
                  name[0].toUpperCase(),
                  style: const TextStyle(
                    fontFamily: robotoSlabFontFamily,
                    fontWeight: FontWeight.w600,
                    fontSize: 32,
                    color: Colors.white,
                  ),
                ),
        ),
        const Gap(10),
        Text(
          name ?? '',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: robotoSlabFontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 19,
            color: recipeLoaderInkColor,
          ),
        ),
        if (badges.isNotEmpty) ...[
          const Gap(8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [for (final badge in badges) _DietBadge(entry: badge)],
          ),
        ],
      ],
    );
  }
}

/// Diets in green, chronic diseases in terracotta.
class _DietBadge extends StatelessWidget {
  const _DietBadge({required this.entry});

  final DietarySummaryEntry entry;

  @override
  Widget build(BuildContext context) {
    final isDisease = entry.stepKey == chronicDiseaseStepKey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: isDisease
            ? homeFridgeTileBackgroundColor
            : recipeLoaderMintColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        entry.label,
        style: TextStyle(
          fontFamily: robotoFontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 10,
          color: isDisease ? optionTerraColor : recipeLoaderGreenColor,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  /// Null while loading.
  final int? value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value?.toString() ?? '–',
            style: const TextStyle(
              fontFamily: robotoSlabFontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 19,
              color: recipeLoaderInkColor,
            ),
          ),
          const Gap(2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: robotoFontFamily,
              fontWeight: FontWeight.w500,
              fontSize: 10.5,
              color: onboardingSubtleTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem {
  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _ProfileMenu extends StatelessWidget {
  const _ProfileMenu({required this.items});

  final List<_ProfileMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in items) ...[
          _ProfileMenuRow(item: item),
          if (item != items.last)
            Divider(
              height: 1,
              thickness: 1,
              color: recipeLoaderInkColor.withValues(alpha: 0.08),
            ),
        ],
      ],
    );
  }
}

class _ProfileMenuRow extends StatelessWidget {
  const _ProfileMenuRow({required this.item});

  final _ProfileMenuItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 15),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: recipeLoaderMintColor,
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, size: 14, color: recipeLoaderGreenColor),
            ),
            const Gap(12),
            Expanded(
              child: Text(
                item.label,
                style: const TextStyle(
                  fontFamily: robotoFontFamily,
                  fontWeight: FontWeight.w500,
                  fontSize: 13.5,
                  color: recipeLoaderInkColor,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: recipeLoaderInkColor.withValues(alpha: 0.35),
            ),
          ],
        ),
      ),
    );
  }
}

class UserProfilePicture extends StatelessWidget {
  const UserProfilePicture({super.key, required this.size, required this.name});

  final double size;
  final String? name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Color(0xffCCD4DE),
        shape: BoxShape.circle,
        border: Border.all(color: greenBrandColor),
      ),
      child: name == null
          ? null
          : Center(
              child: Text(
                name![0].toUpperCase(),
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
    );
  }
}

class DialogLayout extends StatelessWidget {
  const DialogLayout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [const Gap(4), child],
        ),
      ),
    );
  }
}

class PopupTitle extends StatelessWidget {
  const PopupTitle({super.key, required this.title});

  final String title;
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: poppinsFontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class AppLanguageItem {
  final String label;
  final String key;

  AppLanguageItem({required this.label, required this.key});
}

final appLanguagesItem = [
  AppLanguageItem(label: 'English', key: 'en'),
  AppLanguageItem(label: 'Français', key: 'fr'),
];
