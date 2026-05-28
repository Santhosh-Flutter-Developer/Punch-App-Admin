import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sri_hr_admin/core/constants/app_constants.dart';
import 'package:sri_hr_admin/core/theme/app_theme.dart';
import 'package:sri_hr_admin/presentation/companies/widgets/branch_tile.dart';
import 'package:sri_hr_admin/widgets/search_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CompanyController extends GetxController {
  final supabase = Supabase.instance.client;
  final isLoading = true.obs;
  final TextEditingController searchController=TextEditingController();
  final companies = <Map<String, dynamic>>[].obs;
  final filteredCompanies = <Map<String, dynamic>>[].obs;
  final organizations = <Map<String, dynamic>>[].obs;
  final searchQuery = ''.obs;
  final selectedOrgFilter = ''.obs;
  final isSubmitting = false.obs;
  final formKey = GlobalKey<FormState>();
  final selectedOrgId = ''.obs;
  final RxInt selectedIndex = 0.obs;
  final RxBool selected = false.obs;
  final RxBool enable = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
    debounce(
      searchQuery,
      (_) => applyFilter(),
      time: const Duration(milliseconds: 300),
    );
    ever(selectedOrgFilter, (_) => applyFilter());
  }

  Future<void> fetchAll() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        supabase
            .from(AppConstants.tCompanies)
            .select('*, organizations(name, org_prefix)')
            .order('created_at', ascending: false),
        supabase
            .from(AppConstants.tOrganizations)
            .select('id, name, org_prefix')
            .order('name'),
      ]);
      companies.value = List<Map<String, dynamic>>.from(results[0]);
      organizations.value = List<Map<String, dynamic>>.from(results[1]);
      applyFilter();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load companies');
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilter() {
    var list = companies.toList();
    if (searchQuery.isNotEmpty) {
      list = list
          .where(
            (c) =>
                (c['name'] ?? '').toString().toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ) ||
                (c['email'] ?? '').toString().toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ) ||
                (c['city'] ?? '').toString().toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ),
          )
          .toList();
    }
    if (selectedOrgFilter.isNotEmpty) {
      list = list.where((c) => c['org_id'] == selectedOrgFilter.value).toList();
    }
    filteredCompanies.value = list;
  }

  void onSearch(String v) => searchQuery.value = v;

  Widget buildToolbar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          SearchField(
            onSearch: onSearch,
            hintText: "Search companies",
            controller: searchController,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          // Org filter chips
          Obx(
            () => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  filterChip('All', selectedOrgFilter.isEmpty, () {
                    selectedIndex.value = 0;
                    selectedOrgFilter.value = '';
                  }),
                  const SizedBox(width: 8),
                  ...organizations.map(
                    (o) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: filterChip(
                        o['name'],
                        selectedOrgFilter.value == o['id'],
                        () {
                          selectedIndex.value = 0;
                          selectedOrgFilter.value = o['id'];
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget companyBody(BuildContext context) {
    return branchList();
  }

  Widget branchList() {
    return Obx(
      () => selected.value
          ? SizedBox()
          : ListView.separated(
              itemBuilder: (_, i) {
                final c = filteredCompanies[i];
                return BranchTile(
                  company: c,
                  isActive: selectedIndex.value == i,
                  onTap: () {
                    selected.value = true;
                    enable.value = true;
                    selectedIndex.value = i;
                    selectedIndex.refresh();
                    selected.value = false;
                  },
                );
              },
              separatorBuilder: (_, _) =>
                  const Divider(height: 1.0, color: AppTheme.border),
              itemCount: filteredCompanies.length,
            ),
    );
  }

  Widget logoPlaceholder(Map<String, dynamic> c) => Center(
    child: Text(
      c["name"].substring(0, c["name"].length > 2 ? 2 : 1).toUpperCase(),
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: 22,
      ),
    ),
  );

  Widget filterChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          gradient: selected ? AppTheme.secondaryGradient : null,
          color: selected ? null : AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppTheme.secondary.withOpacity(0.3)
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
            color: selected ? Colors.white : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
