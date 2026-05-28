import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sri_hr_admin/core/theme/app_theme.dart';
import 'package:sri_hr_admin/presentation/companies/controller/company_controller.dart';
import 'package:sri_hr_admin/presentation/companies/ui/company_details.dart';
import 'package:sri_hr_admin/widgets/empty_state.dart';
import 'package:sri_hr_admin/widgets/main_layout.dart';
import 'package:sri_hr_admin/widgets/shimmer_list.dart';

class Companies extends StatelessWidget {
  Companies({super.key});

  final controller = Get.isRegistered<CompanyController>()
      ? Get.find<CompanyController>()
      : Get.put(CompanyController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MainLayout(
      title: 'Companies',
      actions: [
        isWide
            ?
              // Refresh
              TextButton.icon(
                onPressed: controller.fetchAll,
                icon: const Icon(Icons.refresh_rounded, size: 15),
                label: const Text('Refresh', style: TextStyle(fontSize: 13)),
              )
            : IconButton(
                onPressed: controller.fetchAll,
                icon: Icon(Icons.refresh_rounded),
              ),
      ],
      child: isWide
          ? wideUI(isDark, context: context, isWide: isWide)
          : narrowUI(isDark, context: context, isWide: isWide),
    );
  }

  Widget branchList(
    bool isDark, {
    required BuildContext context,
    required bool isWide,
  }) {
    return SizedBox(
      height: 500,
      width: 400,
      child: Column(
        children: [
          controller.buildToolbar(isDark),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return ShimmerList();
              }
              if (controller.filteredCompanies.isEmpty) {
                return EmptyState(
                  message: 'No Companies added yet',
                  icon: Icons.apartment_rounded,
                  color: AppTheme.primaryLight,
                );
              }
              return RefreshIndicator(
                onRefresh: controller.fetchAll,
                color: AppTheme.secondary,
                child: controller.companyBody(context, isDark),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget wideUI(
    bool isDark, {
    required BuildContext context,
    required bool isWide,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              branchList(isDark, context: context, isWide: isWide),
              Container(
                width: 1,
                height: double.infinity,
                color: isDark ? AppTheme.sidebarLight : AppTheme.border,
              ),
              Expanded(child: companyDetails()),
            ],
          ),
        ),
      ],
    );
  }

  Widget companyDetails() {
    return Obx(() {
      return controller.filteredCompanies.isEmpty
          ? SizedBox()
          : CompanyDetails(
              key: ValueKey(
                controller.filteredCompanies[controller
                    .selectedIndex
                    .value]['id'],
              ),
              company:
                  controller.filteredCompanies[controller.selectedIndex.value],
              controller: controller,
            );
    });
  }

  Widget narrowUI(
    bool isDark, {
    required BuildContext context,
    required bool isWide,
  }) {
    return Obx(() {
      return controller.enable.value
          ? companyDetails()
          : branchList(isDark, context: context, isWide: isWide);
    });
  }
}
