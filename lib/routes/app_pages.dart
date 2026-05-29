import 'package:get/get.dart';
import 'package:sri_hr_admin/presentation/auth/login/ui/login.dart';
import 'package:sri_hr_admin/presentation/companies/ui/companies.dart';
import 'package:sri_hr_admin/presentation/dashboard/ui/dashboard.dart';
import 'package:sri_hr_admin/presentation/departments/ui/departments.dart';
import 'package:sri_hr_admin/presentation/employees/ui/employees.dart';
import 'package:sri_hr_admin/presentation/organization/ui/organization.dart';
import 'package:sri_hr_admin/routes/app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(name: AppRoutes.login, page: () => const Login()),
    GetPage(name: AppRoutes.dashboard, page: () => const Dashboard()),
    GetPage(name: AppRoutes.organizations, page: () => Organization()),
    GetPage(name: AppRoutes.companies, page: () => Companies()),
    GetPage(name: AppRoutes.departments, page: () => Departments()),
    GetPage(name: AppRoutes.employees, page: () => Employees()),
  ];
}
