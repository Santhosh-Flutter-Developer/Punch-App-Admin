import 'package:flutter/material.dart';

class KPI {
  final String label, change;
  final int value;
  final IconData icon;
  final Color color, darkColor;
  const KPI(
    this.label,
    this.value,
    this.icon,
    this.color,
    this.darkColor,
    this.change,
  );
}
