import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:punch_app_admin/core/constants/app_constants.dart';
import 'package:punch_app_admin/core/theme/app_theme.dart';
import 'package:punch_app_admin/widgets/app_filter_chip.dart';
import 'package:punch_app_admin/widgets/search_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmployeeStatusesController extends GetxController {
  final supabase = Supabase.instance.client;
  final isLoading = true.obs;
  final statuses = <Map<String, dynamic>>[].obs;
  final filteredStatuses = <Map<String, dynamic>>[].obs;
  final searchQuery = ''.obs;
  final selectedCompanyFilter = ''.obs;
  final companies = <Map<String, dynamic>>[].obs;
  final selectedCompanyId = ''.obs;
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
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchAll() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        supabase
            .from(AppConstants.tEmployeeStatus)
            .select('*, companies(name, id)')
            .order('created_at', ascending: false),
        supabase.from('companies').select('id, name').order('name'),
      ]);
      statuses.value = List<Map<String, dynamic>>.from(results[0]);
      companies.value = List<Map<String, dynamic>>.from(results[1]);
      filter();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load statuses');
    } finally {
      isLoading.value = false;
    }
  }

  void filter() {
    var list = statuses.toList();
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list
          .where((s) => (s['name'] ?? '').toString().toLowerCase().contains(q))
          .toList();
    }
    if (selectedCompanyFilter.isNotEmpty) {
      list = list
          .where((s) => s['company_id'] == selectedCompanyFilter.value)
          .toList();
    }
    filteredStatuses.value = list;
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
            hintText: "Search statuses...",
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
                      color: AppTheme.info,
                    ),
                    const SizedBox(width: 8),
                    ...companies.map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: AppFilterChip(
                          label: c['name'],
                          selected: selectedCompanyFilter.value == c['id'],
                          onTap: () => selectedCompanyFilter.value = c['id'],
                          color: AppTheme.info,
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
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.infoLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.info.withOpacity(0.2)),
                  ),
                  child: Text(
                    '${filteredStatuses.length} Statuses',
                    style: const TextStyle(
                      color: AppTheme.info,
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
}
