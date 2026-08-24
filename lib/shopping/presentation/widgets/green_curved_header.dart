import 'package:flutter/material.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/constant.dart';

class GreenCurvedHeader extends StatelessWidget {
  const GreenCurvedHeader({
    super.key,
    required this.title,
    required this.actions,
    this.bottom,
  });

  final String title;
  final List<Widget> actions;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      child: CustomPaint(
        painter: _HeaderPainter(),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: topPadding + 12,
            left: horizontalScreenPadding,
            right: horizontalScreenPadding,
            bottom: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontFamily: poppinsFontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,                        color: Colors.white,
                      ),
                    ),
                  ),
                  ...actions,
                ],
              ),
              if (bottom != null) ...[
                const SizedBox(height: 12),
                bottom!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Solid green gradient rectangle (clipping handles the radius)
    final mainPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF7BC74D),
          const Color(0xFF57B031),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), mainPaint);

    // Decorative circle strokes (subtle)
    final strokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(Offset(w * 0.5, -h * 0.1), h * 0.5, strokePaint);
    canvas.drawCircle(Offset(w * 0.8, h * 0.2), h * 0.7, strokePaint);

    // Decorative orange/yellow curved lines
    final orangePaint = Paint()
      ..color = const Color(0xFFFFAD30).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final orangePath = Path()
      ..moveTo(w * 0.05, h * 0.6)
      ..quadraticBezierTo(w * 0.3, h * 0.1, w * 0.5, h * 0.05)
      ..quadraticBezierTo(w * 0.7, -h * 0.02, w * 0.85, h * 0.3)
      ..quadraticBezierTo(w * 1.0, h * 0.55, w * 0.75, h * 0.85);

    canvas.drawPath(orangePath, orangePaint);

    // Small decorative leaf-like elements
    final leafPaint = Paint()
      ..color = const Color(0xFF3D8B1E).withValues(alpha: 0.3);

    // Top center leaf
    canvas.save();
    canvas.translate(w * 0.48, h * 0.08);
    canvas.rotate(-0.3);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 14, height: 28),
      leafPaint,
    );
    canvas.restore();

    // Top right leaf
    canvas.save();
    canvas.translate(w * 0.72, h * 0.15);
    canvas.rotate(0.5);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 10, height: 22),
      leafPaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
