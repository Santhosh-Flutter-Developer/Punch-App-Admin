import 'package:flutter/material.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:punch_app_admin/core/theme/app_theme.dart';

class ShimmerList extends StatelessWidget {
  const ShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      child: ResponsiveGridRow(
        children: List.generate(5, (i) {
          return ResponsiveGridCol(
            xl: 4,
            lg: 4,
            md: 4,
            xs: 12,
            sm: 12,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                height: 90,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.sidebarLight : AppTheme.surface,
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
