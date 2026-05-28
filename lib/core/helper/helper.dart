import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sri_hr_admin/core/theme/app_theme.dart';

void showSuccess(String msg) => Get.snackbar(
  'Success',
  msg,
  snackPosition: SnackPosition.TOP,
  backgroundColor: const Color(0xFF22C55E),
  colorText: Colors.white,
  duration: const Duration(seconds: 2),
  icon: const Icon(Icons.check_circle, color: Colors.white),
);

void showError(String msg, {String? title}) => Get.snackbar(
  title ?? 'Error',
  msg,
  snackPosition: SnackPosition.TOP,
  backgroundColor: const Color(0xFFEF4444),
  colorText: Colors.white,
  duration: const Duration(seconds: 3),
  icon: const Icon(Icons.error_outline, color: Colors.white),
);

void showDeleteDialog({
  required String title,
  required VoidCallback onConfirm,
}) {
  Get.dialog(
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.delete_rounded,
              color: AppTheme.errorColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Delete',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
      content: Text(
        'Are you sure you want to delete "$title"? This action cannot be undone.',
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            Get.back();
            onConfirm();
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
