import 'package:flutter/material.dart';
import 'package:punch_app_admin/core/theme/app_theme.dart';

class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final Color? bgColor;
  const AppAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 40,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();
    final colors = [
      AppTheme.primaryColor,
      AppTheme.secondary,
      AppTheme.accent,
      AppTheme.warningColor,
      AppTheme.info,
    ];
    final color = colors[name.hashCode.abs() % colors.length];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor ?? color.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? ClipOval(
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _initials(initials, color),
              ),
            )
          : _initials(initials, color),
    );
  }

  Widget _initials(String initials, Color color) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: color,
          fontSize: size * 0.35,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
