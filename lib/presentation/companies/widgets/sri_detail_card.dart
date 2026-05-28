import 'package:flutter/material.dart';
import 'package:sri_hr_admin/core/theme/app_theme.dart';

class SriDetailCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const SriDetailCard({super.key, 
    required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 32, height: 32,
            decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: AppTheme.primaryColor, size: 16)),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary)),
        ]),
        const SizedBox(height: 16),
        const Divider(height: 1, color: AppTheme.border),
        const SizedBox(height: 16),
        ...children,
      ]),
    );
  }
}