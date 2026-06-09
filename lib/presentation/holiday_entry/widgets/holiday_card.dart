import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:punch_app_admin/core/theme/app_theme.dart';

class HolidayCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isDark;
  final int index;
  const HolidayCard({
    super.key,
    required this.item,
    required this.isDark,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final date = item['date'] != null
        ? DateTime.parse(item['date'])
        : DateTime.now();
    final company = item['companies'];
    final gradients = [
      AppTheme.accentGradient,
      AppTheme.primaryGradient,
      AppTheme.secondaryGradient,
      AppTheme.warningGradient,
    ];
    final gradient = gradients[index % gradients.length];
    final colors = [
      AppTheme.accent,
      AppTheme.primaryColor,
      AppTheme.secondary,
      AppTheme.warningColor,
    ];
    final color = colors[index % colors.length];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              // color: AppTheme.accent.withOpacity(0.1),
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('dd').format(date),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                Text(
                  DateFormat('MMM').format(date).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["reason"],
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${item["days"]} day${item["days"] > 1 ? 's' : ''}  •  ${date.year}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.calendar_month_rounded, size: 11, color: color),
                    const SizedBox(width: 3),
                    Text(
                      DateFormat('EEEE').format(date),
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (company != null) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.business_rounded,
                        size: 11,
                        color: AppTheme.textTertiary,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          company['name'] ?? '',
                          style: const TextStyle(
                            color: AppTheme.textTertiary,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
