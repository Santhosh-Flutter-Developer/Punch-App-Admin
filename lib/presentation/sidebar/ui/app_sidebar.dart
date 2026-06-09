import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:punch_app_admin/presentation/auth/controller/app_controller.dart';
import 'package:punch_app_admin/presentation/auth/controller/auth_controller.dart';
import 'package:punch_app_admin/presentation/sidebar/widgets/footer.dart';
import 'package:punch_app_admin/presentation/sidebar/widgets/header.dart';
import 'package:punch_app_admin/presentation/sidebar/widgets/nav_item.dart';
import 'package:punch_app_admin/presentation/sidebar/widgets/nav_tile.dart';
import 'package:punch_app_admin/routes/app_routes.dart';

const items = <NavItem>[
  NavItem('Dashboard', Icons.dashboard_rounded, AppRoutes.dashboard),
  NavItem(
    'Organizations',
    Icons.corporate_fare_rounded,
    AppRoutes.organizations,
  ),
  // NavItem('Designations', Icons.manage_accounts_rounded, AppRoutes.roles),
  NavItem('Companies', Icons.business_rounded, AppRoutes.companies),
  // NavItem('Departments', Icons.account_tree_rounded, AppRoutes.departments),
  NavItem('Employee Statuses', Icons.badge_rounded, AppRoutes.employeeStatuses),
  // NavItem('Salary Types', Icons.payments_rounded, AppRoutes.salaryTypes),
  NavItem('Employees', Icons.people_rounded, AppRoutes.employees),
  NavItem('Holiday Entries', Icons.celebration_rounded, AppRoutes.holidays),
  // NavItem('Leave Requests', Icons.event_busy_rounded, AppRoutes.leaveRequests),
  // NavItem(
  //   'Permission Requests',
  //   Icons.lock_clock_rounded,
  //   AppRoutes.permissionRequests,
  // ),
  NavItem(
    'Attendance Reports',
    Icons.fingerprint_rounded,
    AppRoutes.attendanceLogs,
  ),
  // NavItem(
  //   'Role Permissions',
  //   Icons.security_rounded,
  //   AppRoutes.rolePermissions,
  // ),
  // NavItem('Payments', Icons.credit_card_rounded, AppRoutes.payments),
  NavItem(
    'Subscriptions',
    Icons.subscriptions_rounded,
    AppRoutes.subscriptions,
  ),
  // NavItem(
  //   'Subscription Plans',
  //   Icons.workspace_premium_rounded,
  //   AppRoutes.subscriptionPlans,
  // ),
  // NavItem(
  //   'User Company Access',
  //   Icons.admin_panel_settings_rounded,
  //   AppRoutes.userCompanyAccess,
  // ),
  // NavItem('Users', Icons.person_rounded, AppRoutes.users),
];

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final app = Get.find<AppController>();
    final auth = Get.find<AuthController>();
    const bg = Color(0xFF0A0F1E);
    return Obx(() {
      final expanded = app.isSidebarExpanded.value;
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF0A0F1E),
          statusBarIconBrightness: Brightness.light,
        ),
        child: SafeArea(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            width: expanded ? 242 : 100,
            decoration: BoxDecoration(
              color: bg,
              border: Border(
                right: BorderSide(color: Colors.white.withOpacity(0.05)),
              ),
            ),
            child: Column(
              children: [
                Header(exp: expanded, app: app, auth: auth),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    itemCount: items.length,
                    itemBuilder: (_, i) =>
                        NavTile(item: items[i], app: app, exp: expanded),
                  ),
                ),
                Footer(exp: expanded, app: app, auth: auth),
              ],
            ),
          ),
        ),
      );
    });
  }
}
