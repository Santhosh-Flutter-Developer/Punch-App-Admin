import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:punch_app_admin/core/constants/app_constants.dart';
import 'package:punch_app_admin/core/helper/helper.dart';
import 'package:punch_app_admin/core/theme/app_theme.dart';
import 'package:punch_app_admin/widgets/search_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubscriptionController extends GetxController {
  final supabase = Supabase.instance.client;
  final isLoading = true.obs;
  final subscriptions = <Map<String, dynamic>>[].obs;
  final filteredSubs = <Map<String, dynamic>>[].obs;
  final plans = <Map<String, dynamic>>[].obs;
  final searchQuery = ''.obs;
  final selectedPlanFilter = ''.obs;
  final selectedStatusFilter = ''.obs;
  final TextEditingController searchController = TextEditingController();

  // Pagination
  final currentPage = 1.obs;
  final rowsPerPage = 10.obs;

  List<Map<String, dynamic>> get paginatedSubs {
    final start = (currentPage.value - 1) * rowsPerPage.value;
    if (start >= filteredSubs.length) return [];
    final end = (start + rowsPerPage.value).clamp(0, filteredSubs.length);
    return filteredSubs.sublist(start, end);
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
    ever(selectedPlanFilter, (_) => filter());
    ever(selectedStatusFilter, (_) => filter());
  }

  Future<void> fetchAll() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        supabase
            .from(AppConstants.tSubscriptions)
            .select('''
          id, plan, status, user_limit, start_date, expiry_date, amount, duration, payment_status, created_at,
          companies(name, email)
        ''')
            .order('created_at', ascending: false),
        supabase
            .from(AppConstants.tSubscriptionPlans)
            .select('id, name, monthly_price, yearly_price, user_limit')
            .order('monthly_price'),
      ]);
      subscriptions.value = List<Map<String, dynamic>>.from(results[0]);
      plans.value = List<Map<String, dynamic>>.from(results[1]);
      filter();
    } catch (e) {
      showError("Failed to load subscriptions");
    } finally {
      isLoading.value = false;
    }
  }

  void filter() {
    var list = subscriptions.toList();
    if (searchQuery.isNotEmpty) {
      list = list
          .where(
            (s) => (s['companies']?['name'] ?? '')
                .toString()
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase()),
          )
          .toList();
    }
    if (selectedPlanFilter.isNotEmpty) {
      list = list.where((s) => s['plan'] == selectedPlanFilter.value).toList();
    }
    if (selectedStatusFilter.isNotEmpty) {
      list = list
          .where((s) => s['status'] == selectedStatusFilter.value)
          .toList();
    }
    filteredSubs.value = list;
    currentPage.value = 1;
  }

  void onSearch(String v) => searchQuery.value = v;

  void setPlan(String p) =>
      selectedPlanFilter.value = p == selectedPlanFilter.value ? '' : p;
  void setStatus(String s) =>
      selectedStatusFilter.value = s == selectedStatusFilter.value ? '' : s;

  Widget planChip(
    String label,
    bool selected,
    VoidCallback onTap, {
    Color? color,
    required bool isDark,
  }) {
    final c = color ?? AppTheme.primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? c
              : isDark
              ? AppTheme.sidebarDark
              : AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? c
                : isDark
                ? AppTheme.sidebarDark
                : AppTheme.border,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: c.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget statBadge(String count, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
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

  Widget buildToolbar(BuildContext context, {required bool isDark}) {
    const planColors = {
      'trial': Color(0xFF8B5CF6),
      'basic': Color(0xFF06B6D4),
      'pro': Color(0xFFF59E0B),
      'premium': Color(0xFF6C63FF),
    };
    Color colorFor(String plan) =>
        planColors[plan.toLowerCase()] ?? AppTheme.primaryColor;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: isDark ? AppTheme.sidebarLight : AppTheme.surface,
      child: Column(
        children: [
          SearchField(
            onSearch: onSearch,
            hintText: "Search by Company name...",
            controller: searchController,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          // Plan filter + stats
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Obx(
                    () => Row(
                      children: [
                        planChip(
                          'All Plans',
                          selectedPlanFilter.isEmpty,
                          () => setPlan(''),
                          isDark: isDark,
                        ),
                        const SizedBox(width: 6),
                        ...['trial', 'basic', 'pro', 'premium'].map(
                          (p) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: planChip(
                              p.toUpperCase(),
                              selectedPlanFilter.value == p,
                              () => setPlan(p),
                              color: colorFor(p),
                              isDark: isDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Stats row
          Obx(() {
            final subs = filteredSubs;
            final active = subs.where((s) => s['status'] == 'active').length;
            final expiring = subs.where((s) {
              if (s['expiry_date'] == null) return false;
              final d = DateTime.parse(
                s['expiry_date'],
              ).difference(DateTime.now()).inDays;
              return d >= 0 && d <= 7;
            }).length;
            final expired = subs.where((s) {
              if (s['expiry_date'] == null) return false;
              return DateTime.parse(s['expiry_date']).isBefore(DateTime.now());
            }).length;
            return Row(
              children: [
                statBadge('${subs.length}', 'Total', AppTheme.primaryColor),
                const SizedBox(width: 8),
                statBadge('$active', 'Active', AppTheme.success),
                const SizedBox(width: 8),
                statBadge('$expiring', 'Expiring Soon', AppTheme.warningColor),
                const SizedBox(width: 8),
                statBadge('$expired', 'Expired', AppTheme.errorColor),
              ],
            );
          }),
        ],
      ),
    );
  }
}
