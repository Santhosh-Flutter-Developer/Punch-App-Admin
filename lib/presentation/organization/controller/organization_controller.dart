import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:punch_app_admin/core/constants/app_constants.dart';
import 'package:punch_app_admin/core/helper/helper.dart';
import 'package:punch_app_admin/core/theme/app_theme.dart';
import 'package:punch_app_admin/presentation/organization/widgets/stat_pill.dart';
import 'package:punch_app_admin/widgets/search_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrganizationController extends GetxController {
  final supabase = Supabase.instance.client;
  final isLoading = true.obs;
  final organizations = <Map<String, dynamic>>[].obs;
  final filteredOrgs = <Map<String, dynamic>>[].obs;
  final searchQuery = ''.obs;
  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrganizations();
    debounce(searchQuery, (_) {
      applyFilter();
    }, time: const Duration(milliseconds: 300));
  }

  Future<void> fetchOrganizations() async {
    isLoading.value = true;
    try {
      final data = await supabase
          .from(AppConstants.tOrganizations)
          .select('id, name, org_prefix, owner_id, created_at')
          .order('created_at', ascending: false);
      organizations.value = List<Map<String, dynamic>>.from(data);
      applyFilter();
    } catch (e) {
      showError('Failed to load organizations');
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilter() {
    if (searchQuery.isEmpty) {
      filteredOrgs.value = organizations;
    } else {
      final q = searchQuery.value.toLowerCase();
      filteredOrgs.value = organizations
          .where(
            (o) =>
                (o['name'] ?? '').toString().toLowerCase().contains(q) ||
                (o['org_prefix'] ?? '').toString().toLowerCase().contains(q),
          )
          .toList();
    }
  }

  void onSearch(String val) {
    searchQuery.value = val;
  }

  Widget buildShimmer() {
    return ResponsiveGridRow(
      children: List.generate(5, (i) {
        return ResponsiveGridCol(
          xl: 4,
          lg: 4,
          md: 4,
          xs: 12,
          sm: 12,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget buildToolbar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.sidebarLight : AppTheme.surface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.sidebarLight : AppTheme.border,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SearchField(
                  onSearch: onSearch,
                  hintText: "Search by name or prefix...",
                  isDark: isDark,
                ),
              ),
              SizedBox(width: 10.0),
            ],
          ),
          const SizedBox(height: 12.0),
          Obx(() {
            return Row(
              children: [
                StatPill(
                  count: '${organizations.length}',
                  label: "Total",
                  color: AppTheme.primaryColor,
                  bgColor: AppTheme.primaryColor.withOpacity(0.2),
                  icon: Icons.corporate_fare_rounded,
                ),
                const SizedBox(width: 8.0),
                StatPill(
                  count: '${filteredOrgs.length}',
                  label: "Showing",
                  color: AppTheme.accentColor,
                  bgColor: AppTheme.accentColor.withOpacity(0.2),
                  icon: Icons.filter_list_rounded,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget buildCard(
    bool isDark, {
    required BuildContext context,
    required Map<String, dynamic> org,
    required int index,
  }) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800;
    final createdAt = org['created_at'] != null
        ? DateFormat('MMM d, yyyy').format(DateTime.parse(org['created_at']))
        : '';
    final prefix = (org['org_prefix'] ?? 'ORG').toString();
    final name = (org['name'] ?? '').toString();

    // Color cycling for variety
    final gradients = [
      AppTheme.primaryGradient,
      AppTheme.secondaryGradient,
      AppTheme.accentGradient,
      AppTheme.warningGradient,
      const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF64B5F6)]),
    ];
    final gradient = gradients[index % gradients.length];
    return Padding(
      padding: EdgeInsets.only(bottom: 12.0, right: isWide ? 12.0 : 0.0),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : AppTheme.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),

            splashColor: AppTheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  // Gradient badge with initials
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: gradient.colors.first.withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        prefix.length > 3 ? prefix.substring(0, 3) : prefix,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: isDark
                                ? AppTheme.surface
                                : AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                gradient: gradient,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                prefix,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 11,
                              color: AppTheme.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              createdAt,
                              style: const TextStyle(
                                color: AppTheme.textTertiary,
                                fontSize: 12,
                              ),
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
      ),
    );
  }
}
