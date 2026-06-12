import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:punch_app_admin/core/theme/app_theme.dart';
import 'package:punch_app_admin/presentation/organization/controller/organization_controller.dart';
import 'package:punch_app_admin/widgets/empty_state.dart';
import 'package:punch_app_admin/widgets/main_layout.dart';
import 'package:punch_app_admin/widgets/pagination_controls.dart';

class Organization extends StatelessWidget {
  Organization({super.key});

  final controller = Get.isRegistered<OrganizationController>()
      ? Get.find<OrganizationController>()
      : Get.put(OrganizationController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MainLayout(
      title: "Organizations",
      actions: [
        isWide
            ?
              // Refresh
              TextButton.icon(
                onPressed: () {
                  controller.fetchOrganizations();
                },
                icon: const Icon(Icons.refresh_rounded, size: 15),
                label: const Text('Refresh', style: TextStyle(fontSize: 13)),
              )
            : IconButton(
                onPressed: () {
                  controller.fetchOrganizations();
                },
                icon: Icon(Icons.refresh_rounded),
              ),
      ],
      child: Column(
        children: [
          controller.buildToolbar(isDark),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return controller.buildShimmer();
              }
              if (controller.filteredOrgs.isEmpty) {
                return EmptyState(
                  message: 'No Organization added yet',
                  icon: Icons.toggle_on_rounded,

                  color: AppTheme.primaryLight,
                );
              }
              final pageItems = controller.paginatedOrgs;
              return RefreshIndicator(
                onRefresh: controller.fetchOrganizations,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isWide ? 20 : 10,
                      16,
                      isWide ? 20 : 10,
                      12,
                    ),
                    child: ResponsiveGridRow(
                      children: List.generate(pageItems.length, (
                        i,
                      ) {
                        return ResponsiveGridCol(
                          xl: 4,
                          lg: 4,
                          md: 6,
                          xs: 12,
                          sm: 12,
                          child: controller.buildCard(
                            isDark,
                            context: context,
                            org: pageItems[i],
                            index: i,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              );
            }),
          ),
          Obx(() {
            if (controller.isLoading.value || controller.filteredOrgs.isEmpty) {
              return const SizedBox.shrink();
            }
            return PaginationControls(
              totalItems: controller.filteredOrgs.length,
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
