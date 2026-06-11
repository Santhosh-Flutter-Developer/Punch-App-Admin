import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:punch_app_admin/core/theme/app_theme.dart';

class SubscriptionCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isDark;
  const SubscriptionCard({super.key, required this.item, required this.isDark});
  static const planColors = {
    'trial': Color(0xFF8B5CF6),
    'basic': Color(0xFF06B6D4),
    'pro': Color(0xFFF59E0B),
    'premium': Color(0xFF6C63FF),
  };
  static const planGradients = {
    'trial': LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)]),
    'basic': LinearGradient(colors: [Color(0xFF0891B2), Color(0xFF38BDF8)]),
    'pro': LinearGradient(colors: [Color(0xFFD97706), Color(0xFFFBBF24)]),
    'premium': LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF818CF8)]),
  };

  LinearGradient gradientFor(String plan) =>
      planGradients[plan.toLowerCase()] ?? AppTheme.primaryGradient;
  Color colorFor(String plan) =>
      planColors[plan.toLowerCase()] ?? AppTheme.primaryColor;
  @override
  Widget build(BuildContext context) {
    final plan = (item['plan'] ?? 'trial').toString().toLowerCase();
    final status = (item['status'] ?? 'active').toString();
    final company = item['companies'];
    final expiry = item['expiry_date'] != null
        ? DateTime.parse(item['expiry_date'])
        : null;
    final daysLeft = expiry?.difference(DateTime.now()).inDays;
    final isExpired = daysLeft != null && daysLeft < 0;
    final isExpiringSoon = daysLeft != null && daysLeft >= 0 && daysLeft <= 7;
    final planGradient = gradientFor(plan);
    final planColor = colorFor(plan);
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isExpired
                ? AppTheme.errorColor.withOpacity(0.25)
                : isExpiringSoon
                ? AppTheme.warningColor.withOpacity(0.25)
                : AppTheme.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                gradient: planGradient,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Center(
                      child: Text(
                        (company?['name'] ?? 'C')
                            .toString()
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          company?['name'] ?? '—',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (company?['email'] != null)
                          Text(
                            company!['email'],
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Text(
                      plan.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Details grid
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: detailCell(
                          Icons.calendar_today_rounded,
                          'Start',
                          fmt(item['start_date']),
                          planColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: detailCell(
                          Icons.event_rounded,
                          'Expires',
                          fmt(item['expiry_date']),
                          planColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: detailCell(
                          Icons.people_rounded,
                          'Users',
                          '${item['user_limit'] ?? 0}',
                          planColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: detailCell(
                          Icons.currency_rupee_rounded,
                          'Amount',
                          '₹${item['amount'] ?? 0}',
                          planColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: statusDot(status)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: daysLeftBadge(
                          daysLeft,
                          isExpired,
                          isExpiringSoon,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String fmt(dynamic date) {
    if (date == null) return '—';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(date.toString()));
    } catch (_) {
      return '—';
    }
  }

  Widget statusDot(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
        color = AppTheme.success;
        break;
      case 'expired':
        color = AppTheme.errorColor;
        break;
      default:
        color = AppTheme.warningColor;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.5), blurRadius: 4),
            ],
          ),
        ),
        const SizedBox(width: 5),
        Text(
          status.toUpperCase(),
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget daysLeftBadge(
    int? daysLeft,
    bool isExpired,
    bool isExpiringSoon, {
    bool compact = false,
  }) {
    Color color;
    String text;
    if (isExpired) {
      color = AppTheme.errorColor;
      text = compact ? 'Expired' : '⚠ Expired';
    } else if (isExpiringSoon) {
      color = AppTheme.warningColor;
      text = compact ? '${daysLeft}d left' : '⚡ $daysLeft days left';
    } else {
      color = AppTheme.success;
      text = compact ? '${daysLeft}d left' : '✓ $daysLeft days left';
    }
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: compact ? 10 : 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget detailCell(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 10, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
