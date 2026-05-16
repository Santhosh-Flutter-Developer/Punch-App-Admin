import 'package:flutter/material.dart';

class Orbs extends StatelessWidget {
  final AnimationController bgCtrl;
  const Orbs({super.key, required this.bgCtrl});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        AnimatedBuilder(
          animation: bgCtrl,
          builder: (_, _) => Positioned(
            left: size.width * 0.1 + bgCtrl.value * 30,
            top: size.height * 0.1 - bgCtrl.value * 20,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF3B82F6).withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        AnimatedBuilder(
          animation: bgCtrl,
          builder: (_, _) => Positioned(
            right: size.width * 0.05 - bgCtrl.value * 20,
            bottom: size.height * 0.1 + bgCtrl.value * 30,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF8B5CF6).withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        AnimatedBuilder(
          animation: bgCtrl,
          builder: (_, _) => Positioned(
            left: size.width * 0.4,
            bottom: -50 + bgCtrl.value * 15,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF06B6D4).withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
