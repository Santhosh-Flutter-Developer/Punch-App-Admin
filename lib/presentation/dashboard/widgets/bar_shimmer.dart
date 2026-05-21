import 'package:flutter/material.dart';

class BarShimmer extends StatelessWidget {
  final bool isDark;
  final AnimationController pulseCtrl;
  const BarShimmer({super.key, required this.isDark, required this.pulseCtrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(8, (i) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: AnimatedBuilder(
                animation: pulseCtrl,
                builder: (_, _) => Container(
                  height: 40.0 + i * 12.0 * pulseCtrl.value,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
