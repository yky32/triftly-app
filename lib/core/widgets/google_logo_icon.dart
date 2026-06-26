import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Multicolor Google "G" mark (brand colors) for social sign-in rows.
class GoogleLogoIcon extends StatelessWidget {
  const GoogleLogoIcon({this.size = 22, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  static const _blue = Color(0xFF4285F4);
  static const _green = Color(0xFF34A853);
  static const _yellow = Color(0xFFFBBC05);
  static const _red = Color(0xFFEA4335);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final outer = Rect.fromLTWH(0, 0, w, h);
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = _blue;
    canvas.drawArc(outer, -math.pi / 4, math.pi / 2, true, paint);

    paint.color = _green;
    canvas.drawArc(outer, math.pi / 4, math.pi / 2, true, paint);

    paint.color = _yellow;
    canvas.drawArc(outer, 3 * math.pi / 4, math.pi / 2, true, paint);

    paint.color = _red;
    canvas.drawArc(outer, 5 * math.pi / 4, math.pi / 2, true, paint);

    // Inner cutout
    paint.color = Colors.white;
    canvas.drawCircle(Offset(w / 2, h / 2), w * 0.36, paint);

    // G crossbar
    paint.color = _blue;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.46, h * 0.44, w * 0.38, h * 0.14),
        Radius.circular(h * 0.02),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
