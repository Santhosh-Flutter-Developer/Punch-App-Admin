import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:punch_app_admin/core/theme/app_theme.dart';

class BranchTile extends StatelessWidget {
  final Map<String, dynamic> company;
  final bool isActive;
  final VoidCallback onTap;
  const BranchTile({
    super.key,
    required this.company,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      top: false,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          color: isWide
              ? isActive
                    ? AppTheme.primaryColor.withOpacity(0.06)
                    : Colors.transparent
              : Colors.transparent,
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              Container(
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  color: isWide
                      ? isActive
                            ? AppTheme.primaryColor.withOpacity(0.15)
                            : AppTheme.primaryColor.withOpacity(0.07)
                      : AppTheme.primaryColor.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(12.0),
                  border: isWide
                      ? isActive
                            ? Border.all(
                                color: AppTheme.primaryColor.withOpacity(0.4),
                                width: 2.0,
                              )
                            : null
                      : null,
                ),
                child:
                    company['logo_url'] != null &&
                        company["logo_url"]!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.network(
                          company["logo_url"]!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => initials(company),
                        ),
                      )
                    : initials(company),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            company["name"] ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.0,
                              color: isWide
                                  ? isActive
                                        ? AppTheme.primaryColor
                                        : isDark
                                        ? AppTheme.surface
                                        : AppTheme.textPrimary
                                  : isDark
                                  ? AppTheme.surface
                                  : AppTheme.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isActive && isWide)
                          Container(
                            width: 8.0,
                            height: 8.0,
                            decoration: BoxDecoration(
                              color: AppTheme.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3.0),
                    Text(
                      [
                        if (company["city"]?.isNotEmpty == true)
                          company["city"]!,
                        if (company["state"]?.isNotEmpty == true)
                          company["state"]!,
                      ].join(', '),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3.0),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 11,
                          color: AppTheme.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          company['created_at'] != null
                              ? DateFormat(
                                  'MMM d, yyyy',
                                ).format(DateTime.parse(company['created_at']))
                              : '',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget initials(Map<String, dynamic> c) => Center(
    child: Text(
      c["name"].substring(0, c["name"].length > 1 ? 2 : 1).toUpperCase(),
      style: const TextStyle(
        color: AppTheme.primaryColor,
        fontWeight: FontWeight.w800,
        fontSize: 16,
      ),
    ),
  );
}
