import 'package:flutter/material.dart';

class ShimmerWidget extends StatelessWidget {
  final bool isDark;
  final double w;
  final double h;
  final AnimationController pulseCtrl;
  const ShimmerWidget({
    super.key,
    required this.isDark,
    required this.w,
    required this.h,
    required this.pulseCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseCtrl,
      builder: (_, _) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: isDark
              ? Color.lerp(
                  const Color(0xFF334155),
                  const Color(0xFF1E293B),
                  pulseCtrl.value,
                )
              : Color.lerp(
                  const Color(0xFFE2E8F0),
                  const Color(0xFFF1F5F9),
                  pulseCtrl.value,
                ),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
