import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sri_hr_admin/core/theme/app_theme.dart';
import 'package:sri_hr_admin/presentation/auth/controller/auth_controller.dart';
import 'package:sri_hr_admin/widgets/sri_button.dart';
import 'package:sri_hr_admin/widgets/sri_textfield.dart';

class LoginCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController userCtrl;
  final TextEditingController passCtrl;
  final RxBool obscure;
  const LoginCard({
    super.key,
    required this.formKey,
    required this.userCtrl,
    required this.passCtrl,
    required this.obscure,
  });

  void submit() {
    if (!formKey.currentState!.validate()) return;
    Get.find<AuthController>().login(
      userCtrl.text.trim(),
      passCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.all(36.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.05),
            blurRadius: 40,
            spreadRadius: -5,
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF3B82F6).withOpacity(0.3),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shield_rounded,
                        color: Color(0xFF60A5FA),
                        size: 11,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'SUPER ADMIN',
                        style: TextStyle(
                          color: Color(0xFF60A5FA),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Header
            const Text(
              'Welcome back',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Sign in to manage Sri HR',
              style: TextStyle(
                color: Colors.white.withOpacity(0.45),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            SriTextField(
              label: "Username or Email",
              controller: userCtrl,
              hint: 'admin@company.com',
              prefixIcon: Icons.person_outline_rounded,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Username is required' : null,
            ),
            const SizedBox(height: 20),
            Obx(
              () => SriTextField(
                label: "Password",
                controller: passCtrl,
                hint: '••••••••',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: obscure.value,
                onSuffixTap: () {
                  obscure.value = !obscure.value;
                },
                suffixIcon: obscure.value
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Password is required' : null,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              final err = Get.find<AuthController>().errorMsg.value;
              if (err.isEmpty) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.errorColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppTheme.errorColor,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        err,
                        style: const TextStyle(
                          color: AppTheme.errorColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),
            Obx(() {
              final loading = Get.find<AuthController>().isLoading.value;
              return SriButton(
                label: "Sign In",
                isFullWidth: true,
                isLoading: loading,
                onPressed: loading ? null : submit,
              );
            }),
            const SizedBox(height: 24),
            // Info note
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.07)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Colors.white.withOpacity(0.3),
                    size: 15,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'This panel is restricted to Super Admins only. '
                      'Unauthorized access is not permitted.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 11.5,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                '© 2026 Srisoftwarez. All rights reserved.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.2),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
