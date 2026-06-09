import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:punch_app_admin/core/constants/app_constants.dart';
import 'package:punch_app_admin/core/helper/helper.dart';
import 'package:punch_app_admin/core/theme/app_theme.dart';
import 'package:punch_app_admin/widgets/search_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DepartmentsController extends GetxController {
  final supabase = Supabase.instance.client;
  final isLoading = true.obs;
  final departments = <Map<String, dynamic>>[].obs;
  final filteredDepartments = <Map<String, dynamic>>[].obs;
  final searchQuery = ''.obs;
  final companies = <Map<String, dynamic>>[].obs;
  final selectedCompanyFilter = ''.obs;
  final selectedCompanyId = ''.obs;
  final mobileLogin = false.obs;
  final outsideAttendance = false.obs;
  final formKey = GlobalKey<FormState>();
  final isSubmitting = false.obs;
  final TextEditingController searchController = TextEditingController();

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

  @override
  void onClose() {
    super.onClose();
    searchController.clear();
  }

  Future<void> fetchAll() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        supabase
            .from(AppConstants.tDepartments)
            .select('*, companies(name, id)')
            .order('created_at', ascending: false),
        supabase.from(AppConstants.tCompanies).select('id, name').order('name'),
      ]);
      departments.value = List<Map<String, dynamic>>.from(results[0]);
      companies.value = List<Map<String, dynamic>>.from(results[1]);
      filter();
    } catch (e) {
      showError('Failed to load departments', title: 'Error');
    } finally {
      isLoading.value = false;
    }
  }

  void filter() {
    var list = departments.toList();
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list
          .where(
            (d) =>
                (d['name'] ?? '').toString().toLowerCase().contains(q) ||
                (d['code'] ?? '').toString().toLowerCase().contains(q),
          )
          .toList();
    }
    if (selectedCompanyFilter.isNotEmpty) {
      list = list
          .where((d) => d['company_id'] == selectedCompanyFilter.value)
          .toList();
    }
    filteredDepartments.value = list;
  }

  void onSearch(String v) => searchQuery.value = v;

  Widget buildToolbar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.sidebarLight : AppTheme.surface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.sidebarDark : AppTheme.border,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchField(
            onSearch: onSearch,
            hintText: "Search by name or code...",
            controller: searchController,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          // Company filter chips
          Obx(
            () => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  companyChip(
                    'All Companies',
                    selectedCompanyFilter.isEmpty,
                    () => selectedCompanyFilter.value = '',
                    isDark,
                  ),
                  const SizedBox(width: 6),
                  ...companies.map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: companyChip(
                        c['name'] ?? '',
                        selectedCompanyFilter.value == c['id'],
                        () => selectedCompanyFilter.value = c['id'],
                        isDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Stats
          Obx(
            () => Row(
              children: [
                statPill(
                  '${filteredDepartments.length}',
                  'Departments',
                  AppTheme.secondary,
                  AppTheme.secondaryLight,
                ),
                const SizedBox(width: 8),
                statPill(
                  '${filteredDepartments.where((d) => d['mobile_login'] == true).length}',
                  'Mobile Login',
                  AppTheme.info,
                  AppTheme.infoLight,
                ),
                const SizedBox(width: 8),
                statPill(
                  '${filteredDepartments.where((d) => d['outside_attendance'] == true).length}',
                  'Outside Att.',
                  AppTheme.success,
                  AppTheme.successLight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget companyChip(
    String label,
    bool selected,
    VoidCallback onTap,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: selected ? AppTheme.secondaryGradient : null,
          color: selected
              ? null
              : isDark
              ? AppTheme.sidebarDark
              : AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppTheme.secondary.withOpacity(0.3)
                : isDark
                ? AppTheme.sidebarDark
                : AppTheme.border,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.secondary.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? Colors.white
                : isDark
                ? AppTheme.secondaryLight
                : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget statPill(String count, String label, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCard({
    required BuildContext context,
    required Map<String, dynamic> department,
    required int index,
  }) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final company = department['companies'];
    final mobileLogin = department['mobile_login'] == true;
    final outsideAtt = department['outside_attendance'] == true;
    final code = (department['code'] ?? 'D').toString();
    final name = (department['name'] ?? '').toString();

    // Color rotation
    final colors = [
      AppTheme.secondary,
      AppTheme.primaryColor,
      AppTheme.accent,
      AppTheme.warningColor,
      AppTheme.info,
    ];
    final gradients = [
      AppTheme.secondaryGradient,
      AppTheme.primaryGradient,
      AppTheme.accentGradient,
      AppTheme.warningGradient,
      const LinearGradient(colors: [Color(0xFF0891B2), Color(0xFF38BDF8)]),
    ];
    final color = colors[index % colors.length];
    final gradient = gradients[index % gradients.length];

    return Padding(
      padding: EdgeInsets.only(right: isWide ? 8.0 : 0.0, bottom: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.sidebarDark : AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppTheme.sidebarLight : AppTheme.border,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Code badge
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      code.length > 3 ? code.substring(0, 3) : code,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: isDark
                                    ? AppTheme.surface
                                    : AppTheme.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (company != null)
                        Row(
                          children: [
                            Icon(
                              Icons.business_rounded,
                              size: 11,
                              color: color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              company['name'] ?? '',
                              style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 8),
                      // Feature chips
                      Row(
                        children: [
                          featureBadge(
                            Icons.phone_android_rounded,
                            'Mobile Login',
                            mobileLogin,
                          ),
                          const SizedBox(width: 6),
                          featureBadge(
                            Icons.location_on_rounded,
                            'Outside Att.',
                            outsideAtt,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget featureBadge(IconData icon, String label, bool enabled) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: enabled
            ? AppTheme.successLight
            : AppTheme.errorColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: enabled
              ? AppTheme.success.withOpacity(0.3)
              : AppTheme.errorColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 10,
            color: enabled ? AppTheme.success : AppTheme.errorColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: enabled ? AppTheme.success : AppTheme.errorColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
