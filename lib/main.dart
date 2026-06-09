import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:punch_app_admin/core/theme/app_theme.dart';
import 'package:punch_app_admin/presentation/auth/controller/app_controller.dart';
import 'package:punch_app_admin/presentation/auth/controller/auth_controller.dart';
import 'package:punch_app_admin/routes/app_pages.dart';
import 'package:punch_app_admin/routes/app_routes.dart';
import 'package:punch_app_admin/services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  Get.put(AppController(), permanent: true);
  Get.put(AuthController(), permanent: true);
  runApp(const PunchAppAdmin());
}

class PunchAppAdmin extends StatelessWidget {
  const PunchAppAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    final appCtrl = Get.find<AppController>();
    return Obx(
      () => GetMaterialApp(
        title: 'Punch App Admin',
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
