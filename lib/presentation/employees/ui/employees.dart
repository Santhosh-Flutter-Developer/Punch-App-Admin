import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:punch_app_admin/core/theme/app_theme.dart';
import 'package:punch_app_admin/presentation/employees/controller/employee_controller.dart';
import 'package:punch_app_admin/widgets/empty_state.dart';
import 'package:punch_app_admin/widgets/main_layout.dart';
import 'package:punch_app_admin/widgets/pagination_controls.dart';
import 'package:punch_app_admin/widgets/shimmer_list.dart';

class Employees extends StatelessWidget {
  Employees({super.key});

  final controller = Get.isRegistered<EmployeeController>()
      ? Get.find<EmployeeController>()
      : Get.put(EmployeeController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MainLayout(
      title: 'Employees',
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
      child: Column(
        children: [
          controller.buildToolbar(context, isDark: isDark),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const ShimmerList();
              if (controller.filteredEmployees.isEmpty) {
                return const EmptyState(
                  message: 'No Employees added yet',
                  icon: Icons.apartment_rounded,
                  color: AppTheme.primaryLight,
                );
              }
              return RefreshIndicator(
                onRefresh: controller.fetchAll,
                child: Obx(() => controller.buildGrid(context, isWide,isDark)),
              );
            }),
          ),
          Obx(() {
            if (controller.isLoading.value || controller.filteredEmployees.isEmpty) {
              return const SizedBox.shrink();
            }
            return PaginationControls(
              totalItems: controller.filteredEmployees.length,
              currentPage: controller.currentPage.value,
              rowsPerPage: controller.rowsPerPage.value,
              onRowsPerPageChanged: controller.setRowsPerPage,
              onPageChanged: controller.setPage,
              isDark: isDark,
            );
          }),
        ],
      ),
    );
  }
}
