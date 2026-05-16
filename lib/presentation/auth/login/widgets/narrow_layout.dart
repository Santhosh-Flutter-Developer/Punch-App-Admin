import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sri_hr_admin/presentation/auth/login/widgets/login_card.dart';

class NarrowLayout extends StatelessWidget {
  final Animation<double> cardAnim;
  final GlobalKey<FormState> formKey;
  final TextEditingController userCtrl;
  final TextEditingController passCtrl;
  final RxBool obscure;
  const NarrowLayout({
    super.key,
    required this.cardAnim,
    required this.formKey,
    required this.userCtrl,
    required this.passCtrl,
    required this.obscure,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 80),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // Logo(),
                const SizedBox(height: 32),
                const Text(
                  'Multi-Company HR Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Streamline attendance, leaves, payroll and more — all in one platform.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            child: FadeTransition(
              opacity: cardAnim,
              child: LoginCard(
                formKey: formKey,
                userCtrl: userCtrl,
                passCtrl: passCtrl,
                obscure: obscure,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
