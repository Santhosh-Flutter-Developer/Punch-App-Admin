import 'package:flutter/material.dart';
import 'package:punch_app_admin/core/theme/app_theme.dart';

/// Reusable bottom pagination bar.
///
/// Shows "Rows per page" dropdown, "x-y of total" text and
/// previous/next + page number controls, styled similar to the
/// Attendance Report pagination in the Punch App.
class PaginationControls extends StatelessWidget {
  final int totalItems;
  final int currentPage; // 1-based
  final int rowsPerPage;
  final List<int> rowsPerPageOptions;
  final ValueChanged<int> onRowsPerPageChanged;
  final ValueChanged<int> onPageChanged;
  final bool isDark;

  const PaginationControls({
    super.key,
    required this.totalItems,
    required this.currentPage,
    required this.rowsPerPage,
    required this.onRowsPerPageChanged,
    required this.onPageChanged,
    this.rowsPerPageOptions = const [10, 25, 50, 100],
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final totalPages = totalItems == 0
        ? 1
        : (totalItems / rowsPerPage).ceil();
    final safePage = currentPage.clamp(1, totalPages);

    final start = totalItems == 0 ? 0 : ((safePage - 1) * rowsPerPage) + 1;
    final end = (safePage * rowsPerPage).clamp(0, totalItems);

    final isWide = MediaQuery.of(context).size.width > 700;

    final rowsPerPageWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Rows per page:',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppTheme.textTertiary : AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.sidebarLight : AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF334155)
                  : AppTheme.border,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: rowsPerPage,
              isDense: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: isDark ? AppTheme.textTertiary : AppTheme.textSecondary,
              ),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.surface : AppTheme.textPrimary,
              ),
              dropdownColor: isDark ? AppTheme.sidebarLight : AppTheme.surface,
              items: rowsPerPageOptions
                  .map(
                    (e) => DropdownMenuItem<int>(
                      value: e,
                      child: Text('$e'),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) onRowsPerPageChanged(val);
              },
            ),
          ),
        ),
      ],
    );

    final rangeText = Text(
      '$start–$end of $totalItems',
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: isDark ? AppTheme.textTertiary : AppTheme.textSecondary,
      ),
    );

    final navControls = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _navButton(
          icon: Icons.chevron_left_rounded,
          enabled: safePage > 1,
          onTap: () => onPageChanged(safePage - 1),
          isDark: isDark,
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$safePage / $totalPages',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.surface,
            ),
          ),
        ),
        const SizedBox(width: 6),
        _navButton(
          icon: Icons.chevron_right_rounded,
          enabled: safePage < totalPages,
          onTap: () => onPageChanged(safePage + 1),
          isDark: isDark,
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.sidebarLight : AppTheme.surface,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF334155) : AppTheme.border,
          ),
        ),
      ),
      child: isWide
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                rowsPerPageWidget,
                Row(
                  children: [
                    rangeText,
                    const SizedBox(width: 16),
                    navControls,
                  ],
                ),
              ],
            )
          : Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    rowsPerPageWidget,
                    rangeText,
                  ],
                ),
                const SizedBox(height: 8),
                navControls,
              ],
            ),
    );
  }

  Widget _navButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: isDark ? AppTheme.sidebarLight : AppTheme.surfaceVariant,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : AppTheme.border,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: enabled
                ? (isDark ? AppTheme.surface : AppTheme.textPrimary)
                : AppTheme.textTertiary,
          ),
        ),
      ),
    );
  }
}
