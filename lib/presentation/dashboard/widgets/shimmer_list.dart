import 'package:flutter/material.dart';
import 'package:sri_hr_admin/presentation/dashboard/widgets/shimmer.dart';

class ShimmerList extends StatelessWidget {
  final bool isDark;
  final AnimationController pulseCtrl;
  const ShimmerList({super.key, required this.isDark, required this.pulseCtrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(5, (_) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              ShimmerWidget(isDark: isDark, w: 32, h: 32, pulseCtrl: pulseCtrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerWidget(
                      isDark: isDark,
                      w: 200,
                      h: 12,
                      pulseCtrl: pulseCtrl,
                    ),
                    const SizedBox(height: 6),
                    ShimmerWidget(
                      isDark: isDark,
                      w: 140,
                      h: 10,
                      pulseCtrl: pulseCtrl,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
