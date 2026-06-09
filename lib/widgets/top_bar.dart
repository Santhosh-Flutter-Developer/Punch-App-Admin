import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:punch_app_admin/core/theme/app_theme.dart';
import 'package:punch_app_admin/presentation/auth/controller/app_controller.dart';
import 'package:punch_app_admin/presentation/auth/controller/auth_controller.dart';

class TopBar extends StatelessWidget {
  final AppController app;
  final AuthController auth;
  final String title;
  final List<Widget>? actions;
  const TopBar({
    super.key,
    required this.app,
    required this.auth,
    required this.title,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 60.0,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        children: [
          // Breadcrumb
          Row(
            children: [
              Text(
                'Admin',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 14,
                  color: Color(0xFF94A3B8),
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Custom actions
          ...?actions,
          const SizedBox(width: 4),
          // Theme toggle
          Obx(
            () => Tooltip(
              message: app.isDarkMode.value ? 'Light Mode' : 'Dark Mode',
              child: IconButton(
                onPressed: app.toggleTheme,
                icon: Icon(
                  app.isDarkMode.value
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  size: 19,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Admin user chip with popup
          Obx(
            () => PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'logout') {
                  Get.dialog(
                    AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Row(
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            color: AppTheme.errorColor,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Confirm Logout',
                            style: TextStyle(fontSize: 17),
                          ),
                        ],
                      ),
                      content: const Text(
                        'Sign out of Punch App Admin Panel?',
                        style: TextStyle(fontSize: 13.5),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () {
                            Get.back();
                            auth.logout();
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.errorColor,
                          ),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.adminName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        auth.adminEmail,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? const Color(0xFF64748B)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Divider(height: 1),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        size: 16,
                        color: AppTheme.errorColor,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Sign Out',
                        style: TextStyle(
                          color: AppTheme.errorColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF475569)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          auth.adminInitials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      auth.adminName,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.expand_more_rounded,
                      size: 15,
                      color: isDark ? Colors.white38 : Colors.black26,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
