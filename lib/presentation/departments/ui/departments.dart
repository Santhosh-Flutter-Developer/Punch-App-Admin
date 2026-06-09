import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:punch_app_admin/core/theme/app_theme.dart';
import 'package:punch_app_admin/presentation/departments/controller/departments_controller.dart';
import 'package:punch_app_admin/widgets/empty_state.dart';
import 'package:punch_app_admin/widgets/main_layout.dart';
import 'package:punch_app_admin/widgets/shimmer_list.dart';

class Departments extends StatelessWidget {
  Departments({super.key});

  final controller = Get.isRegistered<DepartmentsController>()
      ? Get.find<DepartmentsController>()
      : Get.put(DepartmentsController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MainLayout(
      title: 'Departments',
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
          controller.buildToolbar(isDark),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return ShimmerList();
              }
              if (controller.filteredDepartments.isEmpty) {
                return EmptyState(
                  icon: Icons.account_tree_rounded,
                  message: 'No departments found',
                );
              }
              return RefreshIndicator(
                onRefresh: controller.fetchAll,
                color: AppTheme.secondary,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ResponsiveGridRow(
                      children: List.generate(
                        controller.filteredDepartments.length,
                        (i) {
                          return ResponsiveGridCol(
                            xl: 4,
                            lg: 4,
                            md: 6,
                            xs: 12,
                            sm: 12,
                            child: controller.buildCard(
                              context: context,
                              department: controller.filteredDepartments[i],
                              index: i,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
