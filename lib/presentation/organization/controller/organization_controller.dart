import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sri_hr_admin/core/theme/app_theme.dart';
import 'package:sri_hr_admin/presentation/auth/controller/app_controller.dart';
import 'package:sri_hr_admin/routes/app_routes.dart';
import 'package:sri_hr_admin/services/supabase_service.dart';
import 'package:sri_hr_admin/widgets/form_dialog.dart';

class OrganizationController extends GetxController {
  Widget buildToolbar(
    bool isDark, {
    required Function(String)? onChanged,
    required bool isGrid,
    required Function() onTap,
    required Future<void> Function(Map<String, dynamic>) onSave,
    required Function() onRefresh,
    required List<Map<String, dynamic>> orgs,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // Search
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextField(
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: 'Search organizations...',
                  hintStyle: const TextStyle(fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, size: 18),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  isDense: true,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          // View toggle
          iconBtn(
            icon: isGrid ? Icons.table_rows_rounded : Icons.grid_view_rounded,
            tooltip: isGrid ? 'Table View' : 'Grid View',
            onTap: onTap,
          ),
          const SizedBox(width: 4),
          iconBtn(
            icon: Icons.refresh_rounded,
            tooltip: 'Refresh',
            onTap: onRefresh,
          ),
          const SizedBox(width: 8),
          // Add button
          FilledButton.icon(
            onPressed: () => showAddOrg(onSave: onSave),
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text(
              'Add Org',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Count badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${orgs.length}',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOrgTabs(
    bool isDark, {
    required TabController tabCtrl,
    required List<Map<String, dynamic>> orgs,
  }) {
    return Container(
      height: 44.0,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TabBar(
        controller: tabCtrl,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        padding: const EdgeInsets.all(4),
        indicator: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(7),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: isDark
            ? const Color(0xFF94A3B8)
            : const Color(0xFF64748B),
        labelStyle: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12.5),
        tabs: [
          const Tab(text: 'All'),
          ...orgs.map((o) => Tab(text: o['name']?.toString() ?? '—')),
        ],
      ),
    );
  }

  Widget buildContent(
    bool isDark, {
    required String search,
    required List<Map<String, dynamic>> filtered,
    required int selectedOrgIdx,
    required List<Map<String, dynamic>> orgs,
    required Future<void> Function(Map<String, dynamic>) onSave,
    required Function() onPressed,
    required List<Map<String, dynamic>> companies,
    required bool isGrid,
  }) {
    // Determine which orgs to show
    final orgsToShow = search.isNotEmpty
        ? filtered
        : (selectedOrgIdx == 0 ? orgs : [orgs[selectedOrgIdx - 1]]);

    if (orgsToShow.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.corporate_fare_rounded,
              size: 56,
              color: Colors.grey.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              search.isNotEmpty
                  ? 'No organizations match "$search"'
                  : 'No organizations yet',
              style: TextStyle(
                color: Colors.grey.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => showAddOrg(onSave: onSave),
              icon: const Icon(Icons.add),
              label: const Text('Add Organization'),
            ),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: orgsToShow
            .map(
              (org) => buildOrgSection(
                org,
                isDark,
                onSave: onSave,
                onPressed: onPressed,
                companies: companies,
                isGrid: isGrid,
              ),
            )
            .toList(),
      ),
    );
  }

  List<Map<String, dynamic>> companiesForOrg(
    String? orgId, {
    required List<Map<String, dynamic>> companies,
  }) {
    if (orgId == null) return companies;
    return companies.where((c) => c['org_id']?.toString() == orgId).toList();
  }

  Widget buildOrgSection(
    Map<String, dynamic> org,
    bool isDark, {
    required Future<void> Function(Map<String, dynamic>) onSave,
    required Function() onPressed,
    required List<Map<String, dynamic>> companies,
    required bool isGrid,
  }) {
    final orgId = org['id']?.toString();
    final orgName = org['name']?.toString() ?? '—';
    final orgCompanies = companiesForOrg(orgId, companies: companies);
    final createdAt = org['created_at']?.toString() ?? '';
    final dateStr = createdAt.length >= 10
        ? createdAt.substring(0, 10)
        : createdAt;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Org header card ───────────────────────────────
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor.withOpacity(0.85),
                AppTheme.accentColor.withOpacity(0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.corporate_fare_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      orgName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.business_rounded,
                          size: 12,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${orgCompanies.length} ${orgCompanies.length == 1 ? 'company' : 'companies'}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 11,
                          color: Colors.white.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dateStr,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Actions
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
                onSelected: (v) {
                  if (v == 'edit') showEditOrg(org, onSave: onSave);
                  if (v == 'delete') confirmDelete(org, onPressed: onPressed);
                  if (v == 'add_company') {
                    showAddCompany(orgId, onCompanySave: onPressed);
                  }
                },
                itemBuilder: (_) => [
                  menuItem(
                    Icons.edit_rounded,
                    AppTheme.primaryColor,
                    'edit',
                    'Edit Org',
                  ),
                  menuItem(
                    Icons.add_business_rounded,
                    AppTheme.successColor,
                    'add_company',
                    'Add Company',
                  ),
                  menuItem(
                    Icons.delete_rounded,
                    AppTheme.errorColor,
                    'delete',
                    'Delete',
                  ),
                ],
              ),
            ],
          ),
        ),
        // ── Companies under this org ──────────────────────
        if (orgCompanies.isEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                ),
                const SizedBox(width: 8),
                Text(
                  'No companies in this organization yet',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () =>
                      showAddCompany(orgId, onCompanySave: onPressed),
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Add', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          )
        else if (isGrid)
          buildCompanyGrid(
            orgCompanies,
            isDark,
            orgId,
            onCompanySave: onPressed,
          )
        else
          buildCompanyList(
            orgCompanies,
            isDark,
            orgId,
            onCompanySave: onPressed,
          ),

        const SizedBox(height: 8),
      ],
    );
  }

  // ── COMPANY GRID ─────────────────────────────────────────────
  Widget buildCompanyGrid(
    List<Map<String, dynamic>> companies,
    bool isDark,
    String? orgId, {
    required Function() onCompanySave,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: LayoutBuilder(
        builder: (ctx, box) {
          int cols = box.maxWidth > 900
              ? 4
              : box.maxWidth > 600
              ? 3
              : 2;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemCount: companies.length + 1,
            itemBuilder: (_, i) {
              if (i == companies.length) {
                // Add company card
                return InkWell(
                  onTap: () =>
                      showAddCompany(orgId, onCompanySave: onCompanySave),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.add_business_rounded,
                            color: AppTheme.primaryColor,
                            size: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Add Company',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              final c = companies[i];
              return companyGridCard(c, isDark, onCompanySave: onCompanySave);
            },
          );
        },
      ),
    );
  }

  Widget companyGridCard(
    Map<String, dynamic> c,
    bool isDark, {
    required Function() onCompanySave,
  }) {
    final name = c['name']?.toString() ?? '—';
    final city = c['city']?.toString() ?? '';
    final state = c['state']?.toString() ?? '';
    final isActive = c['is_active'] == true;
    final phone = c['phone']?.toString() ?? '';
    final location = [city, state].where((s) => s.isNotEmpty).join(', ');

    return InkWell(
      onTap: () => showViewCompany(c, onCompanySave: onCompanySave),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.business_rounded,
                    color: AppTheme.accentColor,
                    size: 18,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    size: 17,
                    color: isDark
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8),
                  ),
                  onSelected: (v) {
                    if (v == 'edit') {
                      showEditCompany(c, onCompanySave: onCompanySave);
                    }
                    if (v == 'delete') {
                      confirmDeleteCompany(c, onCompanySave: onCompanySave);
                    }
                    if (v == 'view') {
                      showViewCompany(c, onCompanySave: onCompanySave);
                    }
                  },
                  itemBuilder: (_) => [
                    menuItem(
                      Icons.visibility_rounded,
                      AppTheme.accentColor,
                      'view',
                      'View',
                    ),
                    menuItem(
                      Icons.edit_rounded,
                      AppTheme.primaryColor,
                      'edit',
                      'Edit',
                    ),
                    menuItem(
                      Icons.delete_rounded,
                      AppTheme.errorColor,
                      'delete',
                      'Delete',
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Text(
              name,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            if (location.isNotEmpty) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 11,
                    color: isDark
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      location,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? const Color(0xFF64748B)
                            : const Color(0xFF94A3B8),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.successColor.withOpacity(0.1)
                    : AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isActive ? 'ACTIVE' : 'INACTIVE',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: isActive ? AppTheme.successColor : AppTheme.errorColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── COMPANY LIST ─────────────────────────────────────────────
  Widget buildCompanyList(
    List<Map<String, dynamic>> companies,
    bool isDark,
    String? orgId, {
    required Function() onCompanySave,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          ...companies.map(
            (c) => companyListTile(c, isDark, onCompanySave: onCompanySave),
          ),
          // Add company button
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: InkWell(
              onTap: () => showAddCompany(orgId, onCompanySave: onCompanySave),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_business_rounded,
                      color: AppTheme.primaryColor,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Add Company to Organization',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget companyListTile(
    Map<String, dynamic> c,
    bool isDark, {
    required Function() onCompanySave,
  }) {
    final name = c['name']?.toString() ?? '—';
    final city = c['city']?.toString() ?? '';
    final state = c['state']?.toString() ?? '';
    final phone = c['phone']?.toString() ?? '';
    final email = c['email']?.toString() ?? '';
    final gstin = c['gstin']?.toString() ?? '';
    final isActive = c['is_active'] == true;
    final branch = c['branch_code']?.toString() ?? '';
    final location = [city, state].where((s) => s.isNotEmpty).join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppTheme.accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(
            Icons.business_rounded,
            color: AppTheme.accentColor,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.successColor.withOpacity(0.1)
                    : AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isActive ? 'ACTIVE' : 'INACTIVE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isActive ? AppTheme.successColor : AppTheme.errorColor,
                ),
              ),
            ),
            if (branch.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  branch,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Wrap(
            spacing: 14,
            children: [
              if (location.isNotEmpty)
                subChip(Icons.location_on_rounded, location, isDark),
              if (phone.isNotEmpty) subChip(Icons.phone_rounded, phone, isDark),
              if (email.isNotEmpty) subChip(Icons.email_rounded, email, isDark),
              if (gstin.isNotEmpty)
                subChip(Icons.receipt_rounded, gstin, isDark),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert_rounded,
            size: 18,
            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          ),
          onSelected: (v) {
            if (v == 'edit') showEditCompany(c, onCompanySave: onCompanySave);
            if (v == 'delete') {
              confirmDeleteCompany(c, onCompanySave: onCompanySave);
            }
            if (v == 'view') showViewCompany(c, onCompanySave: onCompanySave);
          },
          itemBuilder: (_) => [
            menuItem(
              Icons.visibility_rounded,
              AppTheme.accentColor,
              'view',
              'View Details',
            ),
            menuItem(Icons.edit_rounded, AppTheme.primaryColor, 'edit', 'Edit'),
            menuItem(
              Icons.delete_rounded,
              AppTheme.errorColor,
              'delete',
              'Delete',
            ),
          ],
        ),
      ),
    );
  }

  void showEditCompany(
    Map<String, dynamic> c, {
    required Function() onCompanySave,
  }) => Get.dialog(
    FormDialog(
      title: 'Edit Company',
      fields: const [
        FormField2(key: 'name', label: 'Company Name', required: true),
        FormField2(key: 'gstin', label: 'GSTIN'),
        FormField2(key: 'phone', label: 'Phone', type: FormFieldType.phone),
        FormField2(key: 'email', label: 'Email', type: FormFieldType.email),
        FormField2(
          key: 'address',
          label: 'Address',
          type: FormFieldType.textarea,
        ),
        FormField2(key: 'city', label: 'City'),
        FormField2(key: 'state', label: 'State'),
        FormField2(key: 'country', label: 'Country'),
        FormField2(key: 'pincode', label: 'Pincode'),
        FormField2(
          key: 'radius',
          label: 'Radius (m)',
          type: FormFieldType.number,
        ),
        FormField2(key: 'branch_code', label: 'Branch Code'),
        FormField2(
          key: 'is_active',
          label: 'Is Active',
          type: FormFieldType.bool,
        ),
      ],
      initialData: c,
      onSave: (data) async {
        await SupabaseService.update('companies', c['id'], data);
        await onCompanySave();
      },
    ),
  );

  void confirmDeleteCompany(
    Map<String, dynamic> c, {
    required Function() onCompanySave,
  }) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: AppTheme.errorColor, size: 20),
            SizedBox(width: 10),
            Text('Delete Company', style: TextStyle(fontSize: 17)),
          ],
        ),
        content: Text(
          'Delete "${c['name']}"? This action cannot be undone.',
          style: const TextStyle(fontSize: 13.5),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              Get.back();
              await SupabaseService.delete('companies', c['id']);
              await onCompanySave();
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void showViewCompany(
    Map<String, dynamic> c, {
    required Function() onCompanySave,
  }) {
    final isDark = Get.theme.brightness == Brightness.dark;
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.accentColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.business_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c['name']?.toString() ?? '—',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            c['branch_code']?.toString() ?? '',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              // Details
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    detailRow('GSTIN', c['gstin'], isDark),
                    detailRow('Phone', c['phone'], isDark),
                    detailRow('Email', c['email'], isDark),
                    detailRow('Address', c['address'], isDark),
                    detailRow('City', c['city'], isDark),
                    detailRow('State', c['state'], isDark),
                    detailRow('Country', c['country'], isDark),
                    detailRow('Pincode', c['pincode'], isDark),
                    detailRow('Radius', '${c['radius'] ?? 0}m', isDark),
                    detailRow(
                      'Status',
                      c['is_active'] == true ? 'Active' : 'Inactive',
                      isDark,
                      valueColor: c['is_active'] == true
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                    ),
                  ],
                ),
              ),
              // Footer
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Get.back();
                          showEditCompany(c, onCompanySave: onCompanySave);
                        },
                        icon: const Icon(Icons.edit_rounded, size: 15),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          Get.back();
                          Get.find<AppController>().currentRoute.value =
                              AppRoutes.companies;
                          Get.toNamed(AppRoutes.companies);
                        },
                        icon: const Icon(Icons.open_in_new_rounded, size: 15),
                        label: const Text('Full View'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget detailRow(
    String label,
    dynamic value,
    bool isDark, {
    Color? valueColor,
  }) {
    final v = value?.toString().isEmpty ?? true ? '—' : value.toString();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? const Color(0xFF64748B)
                    : const Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              v,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color:
                    valueColor ??
                    (isDark ? Colors.white : const Color(0xFF1E293B)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget subChip(IconData icon, String text, bool isDark) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        icon,
        size: 11,
        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
      ),
      const SizedBox(width: 3),
      Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
        ),
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );

  void showAddCompany(String? orgId, {required Function() onCompanySave}) =>
      Get.dialog(
        FormDialog(
          title: 'Add Company',
          fields: [
            FormField2(
              key: 'org_id',
              label: 'Organization ID',
              type: FormFieldType.uuid,
              hint: orgId ?? '',
            ),
            const FormField2(
              key: 'name',
              label: 'Company Name',
              required: true,
            ),
            const FormField2(key: 'gstin', label: 'GSTIN'),
            const FormField2(
              key: 'phone',
              label: 'Phone',
              type: FormFieldType.phone,
            ),
            const FormField2(
              key: 'email',
              label: 'Email',
              type: FormFieldType.email,
            ),
            const FormField2(
              key: 'address',
              label: 'Address',
              type: FormFieldType.textarea,
            ),
            const FormField2(key: 'city', label: 'City'),
            const FormField2(key: 'state', label: 'State'),
            const FormField2(key: 'country', label: 'Country'),
            const FormField2(key: 'pincode', label: 'Pincode'),
            const FormField2(
              key: 'radius',
              label: 'Radius (m)',
              type: FormFieldType.number,
            ),
            const FormField2(key: 'branch_code', label: 'Branch Code'),
            const FormField2(
              key: 'is_active',
              label: 'Is Active',
              type: FormFieldType.bool,
            ),
          ],
          initialData: {'org_id': orgId, 'is_active': true},
          onSave: (data) async {
            await SupabaseService.insert('companies', data);
            await onCompanySave();
          },
        ),
      );

  void confirmDelete(
    Map<String, dynamic> org, {
    required Function() onPressed,
  }) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: AppTheme.errorColor, size: 20),
            SizedBox(width: 10),
            Text('Delete Organization', style: TextStyle(fontSize: 17)),
          ],
        ),
        content: Text(
          'Delete "${org['name']}"? All associated data may be affected.',
          style: const TextStyle(fontSize: 13.5),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              Get.back();
              await SupabaseService.delete('organizations', org['id']);
              await onPressed();
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void showEditOrg(
    Map<String, dynamic> org, {
    required Future<void> Function(Map<String, dynamic>) onSave,
  }) => Get.dialog(
    FormDialog(
      title: 'Edit Organization',
      fields: const [
        FormField2(key: 'name', label: 'Organization Name', required: true),
        FormField2(
          key: 'owner_id',
          label: 'Owner ID',
          type: FormFieldType.uuid,
        ),
      ],
      initialData: org,
      onSave: onSave,
    ),
  );

  PopupMenuItem<String> menuItem(
    IconData icon,
    Color color,
    String value,
    String label,
  ) => PopupMenuItem(
    value: value,
    child: Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 9),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: value == 'delete' ? AppTheme.errorColor : null,
          ),
        ),
      ],
    ),
  );

  Widget iconBtn({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) => Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 19),
      ),
    ),
  );

  // ── DIALOGS ─────────────────────────────────────────────────
  showAddOrg({required Future<void> Function(Map<String, dynamic>) onSave}) =>
      Get.dialog(
        FormDialog(
          title: 'Add Organization',
          fields: const [
            FormField2(key: 'name', label: 'Organization Name', required: true),
            FormField2(
              key: 'owner_id',
              label: 'Owner ID',
              type: FormFieldType.uuid,
            ),
          ],
          onSave: onSave,
        ),
      );
}
