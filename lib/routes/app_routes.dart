abstract class AppRoutes {
  // Auth
  static const String login = '/login';

  // Super Admin
  static const String dashboard = '/dashboard';
  static const String organizations = '/organizations';
  static const String companies = '/companies';
  static const String departments = '/departments';
  static const String employees = '/employees';
  static const String employeeStatuses = '/employee-statuses';
  static const String roles = '/roles';
  static const String rolePermissions = '/role-permissions';
  static const String salaryTypes = '/salary-types';
  static const String holidays = '/holidays';
  static const String leaveRequests = '/leave-requests';
  static const String permissionRequests = '/permission-requests';
  static const String attendanceLogs = '/attendance-logs';
  static const String payments = '/payments';
  static const String subscriptions = '/subscriptions';
  static const String subscriptionPlans = '/subscription-plans';
  static const String userCompanyAccess = '/user-company-access';
  static const String users = '/users';

  // Normal User
  static const String userDashboard = '/user/dashboard';
  static const String userAttendance = '/user/attendance';
  static const String userLeaves = '/user/leaves';
  static const String userPermissions = '/user/permissions';
  static const String userHolidays = '/user/holidays';
  static const String userProfile = '/user/profile';
  static const String userPayroll = '/user/payroll';
}
