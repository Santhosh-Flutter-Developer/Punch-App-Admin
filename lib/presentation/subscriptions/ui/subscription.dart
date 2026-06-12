import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:punch_app_admin/core/theme/app_theme.dart';
import 'package:punch_app_admin/presentation/subscriptions/controller/subscription_controller.dart';
import 'package:punch_app_admin/presentation/subscriptions/widget/subscription_card.dart';
import 'package:punch_app_admin/widgets/empty_state.dart';
import 'package:punch_app_admin/widgets/main_layout.dart';
import 'package:punch_app_admin/widgets/pagination_controls.dart';
import 'package:punch_app_admin/widgets/shimmer_list.dart';
import 'package:responsive_grid/responsive_grid.dart';

class Subscription extends StatelessWidget {
  Subscription({super.key});

  final controller = Get.isRegistered<SubscriptionController>()
      ? Get.find<SubscriptionController>()
      : Get.put(SubscriptionController());
      
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MainLayout(
      title: "Subscriptions",
      actions: [
        isWide
            ? TextButton.icon(
                onPressed: () => controller.showExportMenu(context),
                icon: const Icon(Icons.download_rounded, size: 15),
                label: const Text('Export', style: TextStyle(fontSize: 13)),
              )
            : IconButton(
                onPressed: () => controller.showExportMenu(context),
                icon: const Icon(Icons.download_rounded),
                tooltip: 'Export',
              ),
        const SizedBox(width: 4),
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
          controller.buildToolbar(context, isDark: isDark,),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const ShimmerList();
              if (controller.filteredSubs.isEmpty) {
                return const EmptyState(
                  message: 'No Subscriptions added yet',
                  icon: Icons.card_membership_rounded,
                  color: AppTheme.primaryLight,
                );
              }
              return RefreshIndicator(
                onRefresh: controller.fetchAll,

                child: ListView(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: 10.0,
                        left: isWide ? 24.0 : 10.0,
                        right: isWide ? 24.0 : 10.0,
                        bottom: 10.0,
                      ),
                      child: ResponsiveGridRow(
                        children: List.generate(
                          controller.paginatedSubs.length,
                          (i) {
                            final item = controller.paginatedSubs[i];
                            return ResponsiveGridCol(
                              xl: 4,
                              lg: 4,
                              md: 6,
                              sm: 12,
                              xs: 12,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: isWide ? 8.0 : 0.0,
                                ),
                                child: SubscriptionCard(item: item,isDark: isDark,),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          Obx(() {
            if (controller.isLoading.value || controller.filteredSubs.isEmpty) {
              return const SizedBox.shrink();
            }
            return PaginationControls(
              totalItems: controller.filteredSubs.length,
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