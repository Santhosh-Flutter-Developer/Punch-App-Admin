import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sri_hr_admin/core/theme/app_theme.dart';
import 'package:sri_hr_admin/presentation/employees/controller/employee_controller.dart';
import 'package:sri_hr_admin/widgets/empty_state.dart';
import 'package:sri_hr_admin/widgets/main_layout.dart';
import 'package:sri_hr_admin/widgets/shimmer_list.dart';

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
        ],
      ),
    );
  }
}
