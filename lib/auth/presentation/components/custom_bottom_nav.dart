import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// ---- Couleurs (adapte si besoin)
const Color barBg = Colors.white;
const Color barStroke = Color(0xFFF0EAD9);
const Color iconIdle = Color(0xFF3F4953);
const Color iconActive = Color(0xFF2DBE48);
const Color fabBg = Color(0xFFFFAD30);

/// ---- Notch très douce façon “U”, plus arrondie que CircularNotchedRectangle
class SoftUNotch extends NotchedShape {
  const SoftUNotch({this.cornerRadius = 18, this.notchRadius = 36});

  final double cornerRadius;
  final double notchRadius;

  @override
  Path getOuterPath(Rect host, Rect? guest) {
    final r = cornerRadius;
    final p = Path()
      ..addRRect(RRect.fromRectAndRadius(host, Radius.circular(r)));

    if (guest == null || guest.isEmpty) return p;

    // Centre du notch
    final c = guest.center;
    final notchR = notchRadius;

    // Découpe un "U" très doux (cubic) dans le bord supérieur
    final top = host.top;
    final left = host.left;
    final right = host.right;

    final notchWidth = notchR * 2.2; // un peu plus large que le FAB
    final notchDepth = notchR * 1.1; // profondeur

    final notchLeftX = c.dx - notchWidth / 2;
    final notchRightX = c.dx + notchWidth / 2;

    // Path du fond puis on soustrait le notch
    final notch = Path()
      ..moveTo(left + r, top) // départ bord sup gauche (après arrondi)
      ..lineTo(notchLeftX, top)
      // cubic qui descend puis remonte (U)
      ..cubicTo(
        notchLeftX + notchWidth * 0.10, top, // contrôle 1
        c.dx - notchWidth * 0.36, top + notchDepth, // contrôle 2
        c.dx, top + notchDepth, // bas du U
      )
      ..cubicTo(
        c.dx + notchWidth * 0.36, top + notchDepth, // contrôle 3
        notchRightX - notchWidth * 0.10, top, // contrôle 4
        notchRightX, top, // sortie U
      )
      ..lineTo(right - r, top)
      ..close();

    // Combine: fond arrondi - encoche
    return Path.combine(PathOperation.difference, p, notch);
  }
}

/// ---- Barre complète (fond, halo, encoche, ombres)
class FancyBottomBar extends StatelessWidget {
  const FancyBottomBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<BarItemData> items;
  final int currentIndex;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Ombre externe douce (carte)
          Container(
            height: 76,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 18,
                  spreadRadius: 0,
                  offset: Offset(0, 6),
                  color: Color(0x1A000000),
                ),
              ],
            ),
          ),

          // Fond + encoche
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: CustomPaint(
              painter: _StrokePainter(), // léger liseré beige
              child: BottomAppBar(
                // Important : on laisse BottomAppBar dessiner le materiel,
                // mais on remplace sa forme par la nôtre (encoche U)
                color: barBg,
                elevation: 0,
                shape: const SoftUNotch(),
                notchMargin: 10,
                height: 76,
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      for (int i = 0; i < 2; i++)
                        _BarItem(
                          data: items[i],
                          index: i,
                          current: currentIndex,
                          onTap: onTap,
                        ),
                      const SizedBox(width: 64), // place pour le FAB
                      for (int i = 2; i < 4; i++)
                        _BarItem(
                          data: items[i],
                          index: i,
                          current: currentIndex,
                          onTap: onTap,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Halo derrière le FAB (glow)
          Positioned(
            top: 0,
            child: IgnorePointer(
              child: Container(
                width: 120,
                height: 60,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 36,
                      spreadRadius: 6,
                      offset: Offset(0, 8),
                      color: Color(0x33FFAD30),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StrokePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(20),
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = barStroke;
    canvas.drawRRect(r, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BarItemData {
  const BarItemData(this.asset);
  final String asset; // chemin SVG
}

class _BarItem extends StatelessWidget {
  const _BarItem({
    required this.data,
    required this.index,
    required this.current,
    required this.onTap,
  });

  final BarItemData data;
  final int index;
  final int current;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final selected = index == current;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Center(
          child: AnimatedScale(
            duration: const Duration(milliseconds: 150),
            scale: selected ? 1.05 : 1.0,
            child: SvgPicture.asset(
              data.asset,
              width: 26,
              height: 26,
              colorFilter: ColorFilter.mode(
                selected ? iconActive : iconIdle,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ---- FAB rond + chef + ombre interne
class ChefFab extends StatelessWidget {
  const ChefFab({super.key, required this.onPressed, this.iconAsset});

  final VoidCallback onPressed;
  final String? iconAsset; // ex: 'assets/icons/chef_hat.svg'

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      height: 76,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // halo discret
          Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  blurRadius: 40,
                  spreadRadius: 0,
                  offset: Offset(0, 6),
                  color: Color(0x33000000),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 22.0, bottom: 10),
            child: FloatingActionButton(
              heroTag: 'chef_fab',
              onPressed: onPressed,
              elevation: 0,
              backgroundColor: fabBg,
              shape: const CircleBorder(),
              child: iconAsset == null
                  ? const Icon(Icons.restaurant, color: Colors.white, size: 28)
                  : SvgPicture.asset(
                      iconAsset!,
                      width: 28,
                      height: 28,
                      colorFilter:
                          const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
