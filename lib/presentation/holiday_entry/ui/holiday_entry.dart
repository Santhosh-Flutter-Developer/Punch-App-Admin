import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:punch_app_admin/core/theme/app_theme.dart';
import 'package:punch_app_admin/presentation/holiday_entry/controller/holiday_entry_controller.dart';
import 'package:punch_app_admin/presentation/holiday_entry/widgets/holiday_card.dart';
import 'package:punch_app_admin/widgets/empty_state.dart';
import 'package:punch_app_admin/widgets/main_layout.dart';
import 'package:punch_app_admin/widgets/pagination_controls.dart';
import 'package:punch_app_admin/widgets/shimmer_list.dart';
import 'package:responsive_grid/responsive_grid.dart';

class HolidayEntry extends StatelessWidget {
  HolidayEntry({super.key});

  final controller = Get.isRegistered<HolidayEntryController>()
      ? Get.find<HolidayEntryController>()
      : Get.put(HolidayEntryController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MainLayout(
      title: "Holiday Entries",
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
              if (controller.filteredHolidays.isEmpty) {
                return const EmptyState(
                  message: 'No Holidays added yet',
                  icon: Icons.apartment_rounded,
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
                          controller.paginatedHolidays.length,
                          (i) {
                            final item = controller.paginatedHolidays[i];
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
                                child: HolidayCard(item: item,isDark: isDark,index: i,),
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
            if (controller.isLoading.value || controller.filteredHolidays.isEmpty) {
              return const SizedBox.shrink();
            }
            return PaginationControls(
              totalItems: controller.filteredHolidays.length,
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
