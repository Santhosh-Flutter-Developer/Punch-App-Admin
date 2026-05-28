import 'package:flutter/material.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:sri_hr_admin/core/theme/app_theme.dart';

class ShimmerList extends StatelessWidget {
  const ShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                height: 90,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
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
