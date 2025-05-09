import 'package:flutter/material.dart';

class PulsingCircle extends StatefulWidget {
  const PulsingCircle({super.key});

  @override
  _PulsingCircleState createState() => _PulsingCircleState();
}

class _PulsingCircleState extends State<PulsingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _radiusAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
    // boucle infinie

    _radiusAnimation = Tween<double>(begin: 50, end: 70).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        children: [
          Center(
            child: AnimatedBuilder(
              animation: _radiusAnimation,
              builder: (_, __) => Container(
                width: _radiusAnimation.value * 2,
                height: _radiusAnimation.value * 2,
                decoration: BoxDecoration(
                  color: Color(0xffffce80),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(0xffffce80),
                    width: 4,
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 65,
              height: 65,
              decoration: const BoxDecoration(
                color: Color(0xffffa61a),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
