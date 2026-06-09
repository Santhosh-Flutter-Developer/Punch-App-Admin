import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:punch_app_admin/core/constants/app_constants.dart';
import 'package:punch_app_admin/core/helper/helper.dart';
import 'package:punch_app_admin/core/theme/app_theme.dart';
import 'package:punch_app_admin/widgets/app_filter_chip.dart';
import 'package:punch_app_admin/widgets/search_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HolidayEntryController extends GetxController {
  final supabase = Supabase.instance.client;
  final isLoading = true.obs;
  final holidays = <Map<String, dynamic>>[].obs;
  final filteredHolidays = <Map<String, dynamic>>[].obs;
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

  Future<void> fetchAll() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        supabase
            .from(AppConstants.tHolidayEntries)
            .select('*, companies(name, id)')
            .order('date', ascending: false),
        supabase.from(AppConstants.tCompanies).select('id, name').order('name'),
      ]);
      holidays.value = List<Map<String, dynamic>>.from(results[0]);
      companies.value = List<Map<String, dynamic>>.from(results[1]);
      filter();
    } catch (e) {
      showError('Failed to load Holidays', title: "Error");
    } finally {
      isLoading.value = false;
    }
  }

  void filter() {
    var list = holidays.toList();
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list
          .where(
            (h) => (h['reason'] ?? '').toString().toLowerCase().contains(q),
          )
          .toList();
    }
    if (selectedCompanyFilter.isNotEmpty) {
      list = list
          .where((h) => h['company_id'] == selectedCompanyFilter.value)
          .toList();
    }
    filteredHolidays.value = list;
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
            hintText: "Search Holidays...",
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
                    color: AppTheme.accent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${filteredHolidays.length} Holidays',
                    style: const TextStyle(
                      color: AppTheme.surface,
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
