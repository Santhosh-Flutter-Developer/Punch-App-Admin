import 'package:flutter/material.dart';

class FeaturePills extends StatelessWidget {
  FeaturePills({super.key});

  final features = [
    (Icons.fingerprint_rounded, 'Attendance Tracking'),
    (Icons.event_busy_rounded, 'Leave Management'),
    (Icons.payments_rounded, 'Payroll System'),
    (Icons.people_rounded, 'Employee Portal'),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: features
          .map(
            (f) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(f.$1, color: Colors.white.withOpacity(0.7), size: 15),
                  const SizedBox(width: 7),
                  Text(
                    f.$2,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
