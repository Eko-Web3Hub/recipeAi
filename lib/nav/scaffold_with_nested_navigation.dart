import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_ai/di/container.dart';
import 'package:recipe_ai/user_account/presentation/translation_controller.dart';

import '../utils/colors.dart';

class NavigationItem extends Equatable {
  const NavigationItem({
    required this.icon,
  });

  final String icon;

  @override
  List<Object?> get props => [icon];
}

const List<NavigationItem> _navigationsItems = [
  NavigationItem(icon: "home"),
  NavigationItem(icon: "union"),
  NavigationItem(icon: "notification-bing"),
  NavigationItem(icon: "profile"),
];

class ScaffoldWithNestedNavigation extends StatelessWidget {
  const ScaffoldWithNestedNavigation({
    Key? key,
    required this.navigationShell,
    required this.hideNavBar,
    this.appBarTitle,
  }) : super(
          key: key ?? const ValueKey<String>("ScaffoldWithNestedNavigation"),
        );
  final StatefulNavigationShell navigationShell;
  final bool hideNavBar;
  final String? appBarTitle;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarTitle != null
          ? AppBar(
              surfaceTintColor: secondaryColor,
              backgroundColor: secondaryColor,
              title: Text(
                appBarTitle!,
                style: Theme.of(context)
                    .textTheme
                    .displayLarge
                    ?.copyWith(fontSize: 17),
              ),
            )
          : null,
      resizeToAvoidBottomInset: false,
      body: navigationShell,
      floatingActionButton: hideNavBar
          ? null
          : Builder(builder: (context) {
              return FloatingActionButton(
                onPressed: () {
                  /// reditect to camera screen
                  // context.go("/home/kitchen-inventory");
                  _showAiActionRecipeBottomSheet(context);
                },
                backgroundColor: greenPrimaryColor,
                shape: const CircleBorder(),
                child: Center(
                  child: SvgPicture.asset('assets/images/aiFillWhite.svg'),
                ),
              );
            }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: hideNavBar
          ? null
          : NavigationBar(
              height: 70,
              surfaceTintColor: Colors.transparent,
              indicatorColor: Colors.transparent,
              backgroundColor: Colors.white,
              selectedIndex: navigationShell.currentIndex,
              indicatorShape: const RoundedRectangleBorder(),
              destinations: _navigationsItems
                  .map<Widget>((NavigationItem item) => Padding(
                        padding: const EdgeInsets.all(15),
                        child: InkWell(
                          onTap: () => _goBranch(
                            _navigationsItems.indexOf(item),
                          ),
                          overlayColor:
                              WidgetStateProperty.all(Colors.transparent),
                          child: SvgPicture.asset(
                            "assets/images/${item.icon}.svg",
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                            colorFilter: ColorFilter.mode(
                              _navigationsItems.indexOf(item) ==
                                      navigationShell.currentIndex
                                  ? greenPrimaryColor
                                  : const Color(0xFFDADADA),
                              BlendMode.srcATop,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
    );
  }
}

void _showAiActionRecipeBottomSheet(BuildContext context) =>
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => _AiGenRecipeBottomSheet(),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
    );

class _AiGenRecipeBottomSheet extends StatelessWidget {
  const _AiGenRecipeBottomSheet();

  @override
  Widget build(BuildContext context) {
    final appText = di<TranslationController>().currentLanguage;

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 19),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Gap(5),
            Center(
              child:
                  SvgPicture.asset('assets/images/rectangleSeparationBar.svg'),
            ),
            const Gap(7),
            Text(
              appText.generateRecipe,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const Gap(32),
            _ActionBtn(
              'assets/images/grocery_icon.svg',
              appText.generateRecipeWithGroceriePhoto,
            ),
            const Gap(12),
            _ActionBtn(
              'assets/images/groceryList.svg',
              appText.generateRecipeWithGrocerieList,
            ),
            const Gap(50),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn(
    this.icon,
    this.title,
  );

  final String icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: 8,
        right: 19,
        bottom: 8,
        left: 19,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Color(0xffD9D9D9),
        ),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            icon,
          ),
          const Gap(10),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Color(0xff333333),
            ),
          ),
        ],
      ),
    );
  }
}
