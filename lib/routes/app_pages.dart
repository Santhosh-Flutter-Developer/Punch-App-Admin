import 'package:get/get.dart';
import 'package:punch_app_admin/presentation/auth/login/ui/login.dart';
import 'package:punch_app_admin/presentation/companies/ui/companies.dart';
import 'package:punch_app_admin/presentation/dashboard/ui/dashboard.dart';
import 'package:punch_app_admin/presentation/departments/ui/departments.dart';
import 'package:punch_app_admin/presentation/employee_statuses/ui/employee_statuses.dart';
import 'package:punch_app_admin/presentation/employees/ui/employees.dart';
import 'package:punch_app_admin/presentation/holiday_entry/ui/holiday_entry.dart';
import 'package:punch_app_admin/presentation/organization/ui/organization.dart';
import 'package:punch_app_admin/routes/app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(name: AppRoutes.login, page: () => const Login()),
    GetPage(name: AppRoutes.dashboard, page: () => const Dashboard()),
    GetPage(name: AppRoutes.organizations, page: () => Organization()),
    GetPage(name: AppRoutes.companies, page: () => Companies()),
    GetPage(name: AppRoutes.departments, page: () => Departments()),
    GetPage(name: AppRoutes.employees, page: () => Employees()),
    GetPage(name: AppRoutes.employeeStatuses, page: () => EmployeeStatuses()),
    GetPage(name: AppRoutes.holidays, page: () => HolidayEntry()),
  ];
}
