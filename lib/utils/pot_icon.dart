import 'package:flutter/material.dart';

/// Small cooking-pot glyph used at the center of the app's loaders.
/// [size] is the icon's width; its height follows the pot's 22:20 ratio.
class PotIcon extends StatelessWidget {
  const PotIcon({super.key, required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final height = size * 20 / 22;
    return SizedBox(
      width: size,
      height: height,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: size / 22,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(size * 10 / 22),
                  topRight: Radius.circular(size * 10 / 22),
                  bottomLeft: Radius.circular(size * 2 / 22),
                  bottomRight: Radius.circular(size * 2 / 22),
                ),
              ),
              child: SizedBox(width: size * 20 / 22, height: size * 11 / 22),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.all(Radius.circular(size * 2 / 22)),
              ),
              child: SizedBox(width: size, height: size * 5 / 22),
            ),
          ),
        ],
      ),
    );
  }
}
