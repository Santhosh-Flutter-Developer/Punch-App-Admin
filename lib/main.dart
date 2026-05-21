import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sri_hr_admin/core/theme/app_theme.dart';
import 'package:sri_hr_admin/presentation/auth/controller/app_controller.dart';
import 'package:sri_hr_admin/presentation/auth/controller/auth_controller.dart';
import 'package:sri_hr_admin/routes/app_pages.dart';
import 'package:sri_hr_admin/routes/app_routes.dart';
import 'package:sri_hr_admin/services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  Get.put(AppController(), permanent: true);
  Get.put(AuthController(), permanent: true);
  runApp(const SriHRAdminApp());
}

class SriHRAdminApp extends StatelessWidget {
  const SriHRAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appCtrl = Get.find<AppController>();
    return Obx(
      () => GetMaterialApp(
        title: 'Sri HR',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: appCtrl.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
        initialRoute: AppRoutes.login,
        getPages: AppPages.routes,
        defaultTransition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 200),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.noScaling),
          child: child!,
        ),
      ),
    );
  }
}
