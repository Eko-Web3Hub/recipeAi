import 'package:flutter/material.dart';
import 'package:recipe_ai/home/presentation/home_screen.dart';
import 'package:recipe_ai/kitchen/presentation/kitchen_inventory_screen.dart';

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
    Container(),
    const KitchenInventoryScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
    // return Scaffold(
    //    resizeToAvoidBottomInset: false,
    //   body: _pages[_selectedPageIndex],
    //   floatingActionButton: FloatingActionButton(
    //     onPressed: () {
    //       selectedPageIndex = 5;
    //     },
    //     backgroundColor: greenPrimaryColor,
    //     shape: const CircleBorder(),
    //     child: const Center(
    //       child: Icon(
    //         Icons.camera_alt_rounded,
    //         color: Colors.white,
    //       ),
    //     ),
    //   ),
    //   floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    //   bottomNavigationBar: AnimatedBottomNavigationBar.builder(
    //     elevation: 200,
    //     blurEffect: true,
    //     backgroundColor: Colors.white,
    //     gapLocation: GapLocation.center,
    //     notchSmoothness: NotchSmoothness.defaultEdge,
    //     activeIndex: selectedPageIndex,
    //     onTap: (index) {
    //       selectedPageIndex = index;
    //     },
    //     itemCount: 4,
    //     tabBuilder: (int index, bool isActive) {
    //       return Padding(
    //         padding: const EdgeInsets.all(15),
    //         child: SvgPicture.asset(
    //           "assets/images/${_icons[index]}.svg",
    //           width: 24,
    //           height: 24,
    //           fit: BoxFit.contain,
    //           colorFilter: ColorFilter.mode(
    //               isActive ? greenPrimaryColor : const Color(0xFFDADADA),
    //               BlendMode.srcATop),
    //         ),
    //       );
    //     },
    //   ),
    // );
  }
}
