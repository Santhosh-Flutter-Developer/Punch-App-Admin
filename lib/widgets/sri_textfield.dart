import 'package:flutter/material.dart';
import 'package:punch_app_admin/core/theme/app_theme.dart';

class SriTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final Color? labelColor;
  final Color? borderColor;
  final Color? iconColor;
  final Color? hintColor;
  final Color? fillColor;
  final Color? textColor;
  final String? hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool enabled;
  final void Function(String)? onChanged;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;

  const SriTextField({
    super.key,
    this.controller,
    this.label,
    this.labelColor,
    this.borderColor,
    this.hintColor,
    this.iconColor,
    this.fillColor,
    this.textColor,
    this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.suffixIcon,
    this.onSuffixTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null && label != "")
          Text(
            label ?? '',
            style: TextStyle(
              color: labelColor ?? Colors.white.withOpacity(0.65),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        if (label != null && label != "") const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: TextStyle(color: textColor ?? Colors.white, fontSize: 14),
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          validator: validator,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: borderColor ?? Colors.white.withOpacity(0.1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: borderColor ?? Colors.white.withOpacity(0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF3B82F6),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.errorColor),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            fillColor: fillColor ?? Colors.white.withOpacity(0.05),
            hintStyle: TextStyle(
              color: hintColor ?? Colors.white.withOpacity(0.25),
              fontSize: 13,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 18, color: iconColor ?? Colors.white38)
                : null,
            suffixIcon: suffixIcon != null
                ? GestureDetector(
                    onTap: onSuffixTap,
                    child: Icon(
                      suffixIcon,
                      size: 20,
                      color: iconColor ?? Colors.white38,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
