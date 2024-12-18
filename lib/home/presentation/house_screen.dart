import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:recipe_ai/home/presentation/home_screen.dart';
import 'package:recipe_ai/utils/colors.dart';

class HouseScreen extends StatefulWidget {
  const HouseScreen({super.key});

  @override
  State<HouseScreen> createState() => _HouseScreenState();
}

class _HouseScreenState extends State<HouseScreen> {
  int _selectedPageIndex = 0;
  int get selectedPageIndex => _selectedPageIndex;
  set selectedPageIndex(int value) {
    setState(() {
      _selectedPageIndex = value;
    });
  }

  final List<Widget> _pages = [
    const HomeScreen(),
    Container(),
    Container(),
    Container(),
    Container()
  ];

  final List<String> _icons = [
    "home",
    "union",
    "notification-bing",
    "profile",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedPageIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: greenPrimaryColor,
        shape: const CircleBorder(),
        child: SvgPicture.asset(
          "assets/images/camera_add.svg",
          width: 24,
          height: 24,
          fit: BoxFit.none,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        leftCornerRadius: 32,
        elevation: 200,
        
        blurEffect: true,
        backgroundColor: Colors.white,
        rightCornerRadius: 50,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.defaultEdge,
        activeIndex: selectedPageIndex,
        onTap: (index) {
          selectedPageIndex = index;
        },
        itemCount: _icons.length,
        tabBuilder: (int index, bool isActive) {
          return Padding(
            padding: const EdgeInsets.all(15),
            child: SvgPicture.asset(
              "assets/images/${_icons[index]}.svg",
              width: 24,
              height: 24,
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(
                  isActive ? greenPrimaryColor : const Color(0xFFDADADA),
                  BlendMode.srcATop),
            ),
          );
        },
      ),
    );
  }
}
