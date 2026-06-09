import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:punch_app_admin/presentation/auth/controller/app_controller.dart';
import 'package:punch_app_admin/presentation/auth/controller/auth_controller.dart';
import 'package:punch_app_admin/presentation/sidebar/ui/app_sidebar.dart';
import 'package:punch_app_admin/widgets/top_bar.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;
  const MainLayout({
    super.key,
    required this.child,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 768;
    final app = Get.find<AppController>();
    final auth = Get.find<AuthController>();
    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            const AppSidebar(),
            Expanded(
              child: Column(
                children: [
                  TopBar(app: app, auth: auth, title: title, actions: actions),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          ...?actions,
          // Obx(
          //   () => IconButton(
          //     icon: Icon(
          //       app.isDarkMode.value
          //           ? Icons.light_mode_rounded
          //           : Icons.dark_mode_rounded,
          //     ),
          //     onPressed: app.toggleTheme,
          //   ),
          // ),
          // IconButton(
          //   icon: const Icon(Icons.logout_rounded, color: AppTheme.errorColor),
          //   onPressed: () => auth.logout(),
          //   tooltip: 'Logout',
          // ),
        ],
      ),
      drawer: const Drawer(child: AppSidebar()),
      body: child,
    );
  }
}
