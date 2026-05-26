import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sri_hr_admin/core/theme/app_theme.dart';
import 'package:sri_hr_admin/presentation/auth/controller/app_controller.dart';
import 'package:sri_hr_admin/presentation/auth/controller/auth_controller.dart';
import 'package:sri_hr_admin/presentation/sidebar/widgets/avatar.dart';

class Footer extends StatelessWidget {
  final bool exp;
  final AppController app;
  final AuthController auth;
  const Footer({
    super.key,
    required this.exp,
    required this.app,
    required this.auth,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800;
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0x0DFFFFFF))),
      ),
      child: Column(
        children: [
          // Admin info card
          if (exp)
            Obx(
              () => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Row(
                  children: [
                    Avatar(initials: auth.adminInitials),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.adminName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Text(
                            'Super Admin',
                            style: TextStyle(
                              color: Color(0xFF8B5CF6),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isWide)
                      Tooltip(
                        message: 'Logout',
                        child: GestureDetector(
                          onTap: () => confirmLogout(auth),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: AppTheme.errorColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppTheme.errorColor.withOpacity(0.2),
                              ),
                            ),
                            child: const Icon(
                              Icons.logout_rounded,
                              color: AppTheme.errorColor,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          // Bottom row: theme toggle + logout
          Row(
            children: [
              if (isWide)
                // Theme
                Obx(
                  () => Tooltip(
                    message: app.isDarkMode.value ? 'Light Mode' : 'Dark Mode',
                    child: GestureDetector(
                      onTap: app.toggleTheme,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          app.isDarkMode.value
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          color: Colors.white30,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              if (exp) const Spacer(),
              const SizedBox(width: 6),
              if (!exp)
                // Logout
                Tooltip(
                  message: 'Logout',
                  child: GestureDetector(
                    onTap: () => confirmLogout(auth),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.errorColor.withOpacity(0.2),
                        ),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: AppTheme.errorColor,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              if (exp && isWide) ...[
                const SizedBox(width: 6),
                Expanded(
                  child: GestureDetector(
                    onTap: () => confirmLogout(auth),
                    child: Container(
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.errorColor.withOpacity(0.2),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            color: AppTheme.errorColor,
                            size: 14,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Logout',
                            style: TextStyle(
                              color: AppTheme.errorColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void confirmLogout(AuthController auth) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppTheme.errorColor, size: 20),
            SizedBox(width: 10),
            Text('Confirm Logout', style: TextStyle(fontSize: 17)),
          ],
        ),
        content: const Text(
          'Are you sure you want to sign out of the admin panel?',
          style: TextStyle(fontSize: 13.5, height: 1.5),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Get.back();
              auth.logout();
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
