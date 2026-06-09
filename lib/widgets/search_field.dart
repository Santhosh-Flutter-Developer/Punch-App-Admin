import 'package:flutter/material.dart';
import 'package:punch_app_admin/core/theme/app_theme.dart';

class SearchField extends StatelessWidget {
  final Function(String)? onSearch;
  final String hintText;
  final bool isDark;
  final TextEditingController? controller;
  const SearchField({
    super.key,
    required this.onSearch,
    required this.hintText,
    required this.isDark,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.sidebarDark : AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppTheme.sidebarDark : AppTheme.border,
        ),
      ),
      child: TextField(
        onChanged: onSearch,
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: AppTheme.textTertiary,
            fontSize: 14,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(10),
            width: 26,
            height: 26,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: const Icon(
              Icons.search_rounded,
              color: AppTheme.primaryColor,
              size: 16,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }
}
