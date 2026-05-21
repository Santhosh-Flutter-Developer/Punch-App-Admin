import 'package:flutter/material.dart';

class Act {
  final String title, sub, time;
  final IconData icon;
  final Color color;
  const Act({
    required this.title,
    required this.sub,
    required this.icon,
    required this.color,
    required this.time,
  });
}
