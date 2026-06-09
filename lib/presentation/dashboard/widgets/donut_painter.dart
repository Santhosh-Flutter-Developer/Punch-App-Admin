import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:punch_app_admin/presentation/dashboard/models/seg.dart';

class DonutPainter extends CustomPainter {
  final List<Seg> segs;
  final double total, progress;
  final bool isDark;
  const DonutPainter({
    required this.segs,
    required this.total,
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0 || segs.isEmpty) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;
    final sw = radius * 0.40;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.butt;

    double angle = -math.pi / 2;
    const gap = 0.04;

    for (final s in segs) {
      final sweep = (s.value / total) * 2 * math.pi * progress - gap;
      if (sweep <= 0) continue;
      paint.color = s.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - sw / 2),
        angle + gap / 2,
        sweep,
        false,
        paint,
      );
      angle += (s.value / total) * 2 * math.pi;
    }

    // Center text
    if (progress > 0.85) {
      final tp = TextPainter(
        text: TextSpan(
          children: [
            TextSpan(
              text: '${total.toInt()}\n',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            TextSpan(
              text: 'records',
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF64748B)
                    : const Color(0xFF94A3B8),
                fontSize: 11,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: radius * 1.4);
      tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(DonutPainter o) => o.progress != progress;
}
