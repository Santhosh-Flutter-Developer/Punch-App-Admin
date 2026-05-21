// ── PAINTERS ───────────────────────────────────────────────────
import 'package:flutter/material.dart';

class DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(0.025);
    const step = 32.0;
    for (double x = step; x < size.width; x += step) {
      for (double y = step; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1.2, p);
      }
    }
  }
  @override
  bool shouldRepaint(_) => false;
}