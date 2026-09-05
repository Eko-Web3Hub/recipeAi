import 'package:flutter/material.dart';
import 'package:recipe_ai/utils/colors.dart';
import 'package:recipe_ai/utils/pot_icon.dart';

/// App-wide spinner: a rotating arc over a faint track, with a pot icon at
/// its center, matching the recipe-generation loader's visual language
/// (see recipe_generation_loader.dart). Set [showIcon] to false in tight or
/// colored-background spots (e.g. a button) where the icon would look cramped.
class CustomCircularLoader extends StatefulWidget {
  const CustomCircularLoader({
    super.key,
    this.size = 50.0,
    this.value,
    this.color,
    this.showIcon = true,
  });

  final double size;
  final double? value;
  final Color? color;
  final bool showIcon;

  @override
  State<CustomCircularLoader> createState() => _CustomCircularLoaderState();
}

class _CustomCircularLoaderState extends State<CustomCircularLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? recipeLoaderGreenColor;
    final strokeWidth = (widget.size / 32).clamp(2.0, 4.0);
    final value = widget.value;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _TrackPainter(
              color: color.withValues(alpha: 0.15),
              strokeWidth: strokeWidth,
            ),
          ),
          if (value != null)
            CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _ArcPainter(
                color: color,
                strokeWidth: strokeWidth,
                startAngle: -1.5707963267948966,
                sweepAngle: value.clamp(0.0, 1.0) * 6.283185307179586,
              ),
            )
          else
            RotationTransition(
              turns: _controller,
              child: CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _ArcPainter(
                  color: color,
                  strokeWidth: strokeWidth,
                  startAngle: -1.5707963267948966,
                  sweepAngle: 1.7453292519943295,
                ),
              ),
            ),
          if (widget.showIcon)
            Container(
              width: widget.size * 56 / 96,
              height: widget.size * 56 / 96,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: PotIcon(color: color, size: widget.size * 22 / 96),
              ),
            ),
        ],
      ),
    );
  }
}

class _TrackPainter extends CustomPainter {
  const _TrackPainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    canvas.drawOval(
      rect,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );
  }

  @override
  bool shouldRepaint(covariant _TrackPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter({
    required this.color,
    required this.strokeWidth,
    required this.startAngle,
    required this.sweepAngle,
  });

  final Color color;
  final double strokeWidth;
  final double startAngle;
  final double sweepAngle;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.startAngle != startAngle ||
      oldDelegate.sweepAngle != sweepAngle;
}
