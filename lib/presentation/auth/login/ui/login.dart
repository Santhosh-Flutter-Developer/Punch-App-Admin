import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:punch_app_admin/presentation/auth/login/widgets/grid_bg_painter.dart';
import 'package:punch_app_admin/presentation/auth/login/widgets/narrow_layout.dart';
import 'package:punch_app_admin/presentation/auth/login/widgets/orbs.dart';
import 'package:punch_app_admin/presentation/auth/login/widgets/wide_layout.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  RxBool obscure = true.obs;
  late AnimationController bgCtrl;
  late AnimationController cardCtrl;
  late Animation<double> cardAnim;

  @override
  void initState() {
    super.initState();
    bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    cardAnim = CurvedAnimation(parent: cardCtrl, curve: Curves.easeOutBack);
    cardCtrl.forward();
  }

  @override
  void dispose() {
    bgCtrl.dispose();
    cardCtrl.dispose();
    userCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800;
    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: bgCtrl,
            builder: (_, _) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: const [
                    Color(0xFF0F172A),
                    Color(0xFF1E293B),
                    Color(0xFF0F2040),
                  ],
                  begin: Alignment(-1 + bgCtrl.value * 0.4, -1),
                  end: Alignment(1, 1 - bgCtrl.value * 0.3),
                ),
              ),
            ),
          ),
          // Floating orbs
          Orbs(bgCtrl: bgCtrl),
          // Grid overlay
          CustomPaint(size: size, painter: GridBgPainter()),
          // Content
          isWide
              ? WideLayout(
                  cardAnim: cardAnim,
                  formKey: formKey,
                  userCtrl: userCtrl,
                  passCtrl: passCtrl,
                  obscure: obscure,
                )
              : NarrowLayout(
                  cardAnim: cardAnim,
                  formKey: formKey,
                  userCtrl: userCtrl,
                  passCtrl: passCtrl,
                  obscure: obscure,
                ),
        ],
      ),
    );
  }
}
