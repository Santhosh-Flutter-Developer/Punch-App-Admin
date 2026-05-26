import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sri_hr_admin/presentation/auth/controller/app_controller.dart';
import 'package:sri_hr_admin/presentation/auth/controller/auth_controller.dart';

class Header extends StatelessWidget {
  final bool exp;
  final AppController app;
  final AuthController auth;
  const Header({
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
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x0DFFFFFF))),
      ),
      child: Row(
        children: [
          // Logo icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(11),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          if (exp) ...[
            Expanded(
              child: Obx(
                () => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sri HR Admin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      auth.companyName,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 10.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (!isWide)
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
          if (isWide)
            // Collapse toggle
            GestureDetector(
              onTap: app.toggleSidebar,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(
                  exp
                      ? Icons.chevron_left_rounded
                      : Icons.chevron_right_rounded,
                  color: Colors.white24,
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
