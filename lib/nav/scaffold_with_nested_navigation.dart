import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

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
  }) : super(
          key: key ?? const ValueKey<String>("ScaffoldWithNestedNavigation"),
        );
  final StatefulNavigationShell navigationShell;
  final bool hideNavBar;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: navigationShell,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          /// reditect to camera screen
        },
        backgroundColor: greenPrimaryColor,
        shape: const CircleBorder(),
        child: const Center(
          child: Icon(
            Icons.camera_alt_rounded,
            color: Colors.white,
          ),
        ),
      ),
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
