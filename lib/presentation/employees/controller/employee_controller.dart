import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:punch_app_admin/presentation/employees/ui/employee_details.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:punch_app_admin/core/constants/app_constants.dart';
import 'package:punch_app_admin/core/helper/helper.dart';
import 'package:punch_app_admin/core/theme/app_theme.dart';
import 'package:punch_app_admin/presentation/employees/widgets/app_avatar.dart';
import 'package:punch_app_admin/widgets/app_filter_chip.dart';
import 'package:punch_app_admin/widgets/search_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmployeeController extends GetxController {
  final supabase = Supabase.instance.client;
  final isLoading = true.obs;
  final employees = <Map<String, dynamic>>[].obs;
  final filteredEmployees = <Map<String, dynamic>>[].obs;
  final searchQuery = ''.obs;
  final selectedCompanyFilter = ''.obs;
  final companies = <Map<String, dynamic>>[].obs;
  final TextEditingController searchController = TextEditingController();

  // Pagination
  final currentPage = 1.obs;
  final rowsPerPage = 10.obs;

  List<Map<String, dynamic>> get paginatedEmployees {
    final start = (currentPage.value - 1) * rowsPerPage.value;
    if (start >= filteredEmployees.length) return [];
    final end = (start + rowsPerPage.value).clamp(0, filteredEmployees.length);
    return filteredEmployees.sublist(start, end);
  }

  void setRowsPerPage(int val) {
    rowsPerPage.value = val;
    currentPage.value = 1;
  }

  void setPage(int page) {
    currentPage.value = page;
  }

  @override
  void onInit() {
    super.onInit();
    fetchAll();
    debounce(
      searchQuery,
      (_) => filter(),
      time: const Duration(milliseconds: 300),
    );
    ever(selectedCompanyFilter, (_) => filter());
  }

  Future<void> fetchAll() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        supabase
            .from(AppConstants.tEmployees)
            .select('''
          id, company_id, full_name, employee_code, email, mobile, gender,
          doj, dob, father_husband_name, address, aadhar_address,
          country, state, city, pincode, casual_leave, mobile_login,
          outside_office, is_active, profile_picture, created_at,
          other_doc_url, aadhar_doc_url,
          companies(name, city),
          departments(name),
          roles(name),
          employee_statuses(name)
        ''')
            .order('created_at', ascending: false),
        supabase.from(AppConstants.tCompanies).select('id, name').order('name'),
      ]);
      employees.value = List<Map<String, dynamic>>.from(results[0]);
      companies.value = List<Map<String, dynamic>>.from(results[1]);
      filter();
    } catch (e) {
      showError('Failed to load employees', title: "Error");
    } finally {
      isLoading.value = false;
    }
  }

  void filter() {
    var list = employees.toList();
    if (searchQuery.isNotEmpty) {
      list = list
          .where(
            (e) =>
                (e['full_name'] ?? '').toString().toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ) ||
                (e['employee_code'] ?? '').toString().toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ) ||
                (e['email'] ?? '').toString().toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ),
          )
          .toList();
    }
    if (selectedCompanyFilter.isNotEmpty) {
      list = list.where((e) {
        return e['company_id'] == selectedCompanyFilter.value;
      }).toList();
    }
    filteredEmployees.value = list;
    currentPage.value = 1;
  }

  void onSearch(String v) => searchQuery.value = v;

  Widget buildToolbar(BuildContext context, {required bool isDark}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: isDark ? AppTheme.sidebarLight : AppTheme.surface,
      child: Column(
        children: [
          SearchField(
            onSearch: onSearch,
            hintText: "Search employees...",
            controller: searchController,
            isDark: isDark,
          ),
          const SizedBox(height: 10.0),
          Obx(
            () => Align(
              alignment: Alignment.topLeft,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AppFilterChip(
                      label: 'All Companies',
                      selected: selectedCompanyFilter.isEmpty,
                      onTap: () => selectedCompanyFilter.value = '',
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    ...companies.map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: AppFilterChip(
                          label: c['name'],
                          selected: selectedCompanyFilter.value == c['id'],
                          onTap: () => selectedCompanyFilter.value = c['id'],
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Obx(
            () => Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${filteredEmployees.length} Employees',
                    style: const TextStyle(
                      color: AppTheme.surface,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.successLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${filteredEmployees.where((e) => e['is_active'] == true).length} Active',
                    style: const TextStyle(
                      color: AppTheme.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGrid(BuildContext context, bool isWide, bool isDark) {
    final items = paginatedEmployees;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ResponsiveGridRow(
          children: List.generate(items.length, (i) {
            return ResponsiveGridCol(
              xl: 4,
              lg: 4,
              md: 6,
              xs: 12,
              sm: 12,
              child: buildListCard(
                employee: items[i],
                isWide: isWide,
                isDark: isDark,
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget buildListCard({
    required Map<String, dynamic> employee,
    required bool isWide,
    required bool isDark,
  }) {
    final isActive = employee['is_active'] == true;
    final dept = employee['departments'];
    final role = employee['roles'];
    final company = employee['companies'];
    final status = employee['employee_statuses'];
    final createdAt = employee['created_at'] != null
        ? DateFormat(
            'MMM d, yyyy',
          ).format(DateTime.parse(employee['created_at']))
        : '';
    return Padding(
      padding: EdgeInsets.only(right: isWide ? 8.0 : 0.0, bottom: 10.0),
      child: GestureDetector(
        onTap: () => Get.to(
          () => EmployeeDetail(employee: employee),
          transition: Transition.rightToLeft,
        ),
        child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.sidebarDark : AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppTheme.sidebarLight : AppTheme.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Stack(
                children: [
                  AppAvatar(
                    imageUrl: employee['profile_picture'],
                    name: employee['full_name'] ?? 'E',
                    size: 52,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppTheme.success
                            : AppTheme.textTertiary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            employee['full_name'] ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: isDark
                                  ? AppTheme.secondaryLight
                                  : AppTheme.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (status != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.infoLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              status['name'] ?? '',
                              style: const TextStyle(
                                color: AppTheme.info,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            employee['employee_code'] ?? '',
                            style: const TextStyle(
                              color: AppTheme.secondaryLight,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (employee['gender'] != null &&
                            employee['gender'].toString().isNotEmpty &&
                            employee['gender'] != 'NULL')
                          Text(
                            employee['gender'],
                            style: const TextStyle(
                              color: AppTheme.textTertiary,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (dept != null)
                          tag(
                            Icons.account_tree_rounded,
                            dept['name'] ?? '',
                            AppTheme.secondary,
                          ),
                        if (role != null)
                          tag(
                            Icons.shield_rounded,
                            role['name'] ?? '',
                            AppTheme.info,
                          ),
                        if (company != null)
                          tag(
                            Icons.business_rounded,
                            company['name'] ?? '',
                            AppTheme.accent,
                          ),
                      ],
                    ),
                    if ((employee['email'] ?? '').toString().isNotEmpty &&
                        employee['email'] != 'NULL') ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.email_outlined,
                            size: 12,
                            color: AppTheme.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              employee['email'],
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 11,
                            color: AppTheme.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            createdAt,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      ),  // GestureDetector
    );
  }

  Widget tag(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}