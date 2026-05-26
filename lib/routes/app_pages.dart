import 'package:get/get.dart';
import 'package:sri_hr_admin/presentation/auth/login/ui/login.dart';
import 'package:sri_hr_admin/presentation/dashboard/ui/dashboard.dart';
import 'package:sri_hr_admin/routes/app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(name: AppRoutes.login, page: () => const Login()),
    GetPage(name: AppRoutes.dashboard, page: () => const Dashboard()),
    // GetPage(name: AppRoutes.organizations, page: () => const Organization()),
  ];
}
