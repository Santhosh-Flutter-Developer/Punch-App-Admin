import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:punch_app_admin/presentation/auth/login/widgets/feature_pills.dart';
import 'package:punch_app_admin/presentation/auth/login/widgets/login_card.dart';
import 'package:punch_app_admin/presentation/auth/login/widgets/logo.dart';

class WideLayout extends StatelessWidget {
  final Animation<double> cardAnim;
  final GlobalKey<FormState> formKey;
  final TextEditingController userCtrl;
  final TextEditingController passCtrl;
  final RxBool obscure;
  const WideLayout({
    super.key,
    required this.cardAnim,
    required this.formKey,
    required this.userCtrl,
    required this.passCtrl,
    required this.obscure,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left branding panel
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.all(60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Logo(),
                const SizedBox(height: 48),
                const Text(
                  'Super Admin Control Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Streamline attendance, leaves, payroll and more — all in one platform.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 48),
                FeaturePills(),
              ],
            ),
          ),
        ),
        // Right login card
        Expanded(
          flex: 4,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: ScaleTransition(
                scale: cardAnim,
                child: LoginCard(
                  formKey: formKey,
                  userCtrl: userCtrl,
                  passCtrl: passCtrl,
                  obscure: obscure,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
