import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sri_hr_admin/core/theme/app_theme.dart';
import 'package:sri_hr_admin/presentation/auth/controller/app_controller.dart';
import 'package:sri_hr_admin/presentation/dashboard/models/act.dart';
import 'package:sri_hr_admin/presentation/dashboard/models/bar.dart';
import 'package:sri_hr_admin/presentation/dashboard/models/kpi.dart';
import 'package:sri_hr_admin/presentation/dashboard/models/mod.dart';
import 'package:sri_hr_admin/presentation/dashboard/models/seg.dart';
import 'package:sri_hr_admin/presentation/dashboard/models/summ_stat.dart';
import 'package:sri_hr_admin/presentation/dashboard/widgets/bar_shimmer.dart';
import 'package:sri_hr_admin/presentation/dashboard/widgets/card_widget.dart';
import 'package:sri_hr_admin/presentation/dashboard/widgets/donut_painter.dart';
import 'package:sri_hr_admin/presentation/dashboard/widgets/shimmer.dart';
import 'package:sri_hr_admin/presentation/dashboard/widgets/shimmer_list.dart';
import 'package:sri_hr_admin/routes/app_routes.dart';
import 'package:sri_hr_admin/services/supabase_service.dart';
import 'package:sri_hr_admin/presentation/dashboard/widgets/dot_grid_painter.dart';
import 'package:sri_hr_admin/widgets/hero_pill.dart';

class DashboardController extends GetxController {
  RxMap<String, int> counts = <String, int>{}.obs;
  RxList<Map<String, dynamic>> recentLeaves = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> recentAttendance = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> recentUsers = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> recentPayments = <Map<String, dynamic>>[].obs;
  RxBool loading = false.obs;
  RxString? error;

  // Animation
  late AnimationController pulseCtrl;
  late AnimationController fadeCtrl;
  late Animation<double> fadeAnim;

  // Filter
  String selectedPeriod = 'All Time';
  final periods = ['All Time', 'Today', 'This Week', 'This Month'];

  Future<void> load() async {
    loading.value = true;
    error?.value = "";
    try {
      final tables = [
        'organizations',
        'companies',
        'departments',
        'employees',
        'users',
        'roles',
        'leave_requests',
        'attendance_logs',
        'payments',
        'subscriptions',
        'holidays',
        'permission_requests',
        'salary_types',
        'subscription_plans',
        'role_permissions',
      ];
      final results = await Future.wait([
        ...tables.map((t) => SupabaseService.fetchAll(t)),
        //Recent activity queries
        SupabaseService.client
            .from('leave_requests')
            .select('*')
            .order('created_at', ascending: false)
            .limit(5),
        SupabaseService.client
            .from('attendance_logs')
            .select('*')
            .order('created_at', ascending: false)
            .limit(5),
        SupabaseService.client
            .from('users')
            .select('*')
            .order('created_at', ascending: false)
            .limit(5),
        SupabaseService.client
            .from('payments')
            .select('*')
            .order('created_at', ascending: false)
            .limit(5),
      ]);

      final count = <String, int>{};
      for (int i = 0; i < tables.length; i++) {
        count[tables[i]] = (results[i] as List).length;
      }

      counts.value = count;
      recentLeaves.value = List<Map<String, dynamic>>.from(
        results[tables.length] as List,
      );
      recentAttendance.value = List<Map<String, dynamic>>.from(
        results[tables.length + 1] as List,
      );
      recentUsers.value = List<Map<String, dynamic>>.from(
        results[tables.length + 2] as List,
      );
      recentPayments.value = List<Map<String, dynamic>>.from(
        results[tables.length + 3] as List,
      );

      loading.value = false;
      fadeCtrl.forward(from: 0);
    } catch (e) {
      loading.value = false;
      error?.value = e.toString();
      debugPrint('Dashboard load error:$e');
    }
  }

  Widget buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 56,
            color: AppTheme.errorColor,
          ),
          const SizedBox(height: 16),
          const Text(
            'Failed to load dashboard data',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            error != null ? error!.value : '',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: load,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget heroBanner(bool isDark) {
    return Obx(
      () => Container(
        height: 180.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF060B18), Color(0xFF0D1B35), Color(0xFF0A1628)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Animated orb
            AnimatedBuilder(
              animation: pulseCtrl,
              builder: (_, _) => Positioned(
                right: -40 + pulseCtrl.value * 20,
                top: -40 + pulseCtrl.value * 10,
                child: Container(
                  width: 200 + pulseCtrl.value * 30,
                  height: 200 + pulseCtrl.value * 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF3B82F6).withOpacity(0.12),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 180,
              top: 20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF06B6D4).withOpacity(0.08),
                ),
              ),
            ),
            CustomPaint(
              size: const Size(double.infinity, 180),
              painter: DotGridPainter(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 22, 24, 22),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF3B82F6).withOpacity(0.35),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                color: Color(0xFF60A5FA),
                                size: 11,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'SUPER ADMIN',
                                style: TextStyle(
                                  color: Color(0xFF60A5FA),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        //Title
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sri HR Admin',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Complete HR operations control panel',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.45),
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                        // Pills
                        Row(
                          children: [
                            HeroPill(
                              n: '${counts['companies'] ?? 0}',
                              label: 'Companies',
                              icon: Icons.business_rounded,
                              color: Color(0xFF3B82F6),
                            ),
                            const SizedBox(width: 8),
                            HeroPill(
                              n: '${counts['employees'] ?? 0}',
                              label: 'Employees',
                              icon: Icons.people_rounded,
                              color: Color(0xFF10B981),
                            ),
                            const SizedBox(width: 8),
                            HeroPill(
                              n: '${counts['subscriptions'] ?? 0}',
                              label: "Subs",
                              icon: Icons.workspace_premium_rounded,
                              color: Color(0xFF8B5CF6),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF3B82F6).withOpacity(0.2),
                          const Color(0xFF06B6D4).withOpacity(0.2),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.12),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget kpiRow(bool isDark) {
    final kpis = [
      KPI(
        'Total Employees',
        counts['employees'] ?? 0,
        Icons.people_rounded,
        const Color(0xFF3B82F6),
        const Color(0xFF1D4ED8),
        '↑ 12%',
      ),
      KPI(
        'Active Companies',
        counts['companies'] ?? 0,
        Icons.business_rounded,
        const Color(0xFF10B981),
        const Color(0xFF047857),
        '↑ 5%',
      ),
      KPI(
        'Leave Requests',
        counts['leave_requests'] ?? 0,
        Icons.event_busy_rounded,
        const Color(0xFFF59E0B),
        const Color(0xFFB45309),
        '${recentLeaves.where((l) => l['status'] == 'pending').length} pending',
      ),
      KPI(
        'Subscriptions',
        counts['subscriptions'] ?? 0,
        Icons.workspace_premium_rounded,
        const Color(0xFF8B5CF6),
        const Color(0xFF6D28D9),
        'active',
      ),
    ];
    return LayoutBuilder(
      builder: (_, box) {
        int cols = box.maxWidth > 800
            ? 4
            : box.maxWidth > 500
            ? 2
            : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: cols == 1 ? 3.5 : 1.85,
          ),
          itemCount: kpis.length,
          itemBuilder: (_, i) {
            final k = kpis[i];
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 350 + i * 80),
              builder: (_, v, child) {
                return Transform.translate(
                  offset: Offset(0, 16 * (1 - v)),
                  child: Opacity(opacity: v, child: child),
                );
              },
              child: InkWell(
                onTap: () {
                  // Navigate to related screen
                  final routes = [
                    AppRoutes.employees,
                    AppRoutes.companies,
                    AppRoutes.leaveRequests,
                    AppRoutes.subscriptions,
                  ];
                  Get.find<AppController>().currentRoute.value = routes[i];
                  Get.toNamed(routes[i]);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: k.color.withOpacity(0.07),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [k.color, k.darkColor],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(k.icon, color: Colors.white, size: 20),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: k.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              k.change,
                              style: TextStyle(
                                fontSize: 10,
                                color: k.color,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Obx(
                        () => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            loading.value
                                ? ShimmerWidget(
                                    isDark: isDark,
                                    w: 44,
                                    h: 26,
                                    pulseCtrl: pulseCtrl,
                                  )
                                : TweenAnimationBuilder<int>(
                                    tween: IntTween(begin: 0, end: k.value),
                                    duration: const Duration(
                                      milliseconds: 1000,
                                    ),
                                    curve: Curves.easeOut,
                                    builder: (_, v, _) => Text(
                                      '$v',
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                        color: k.color,
                                        height: 1,
                                      ),
                                    ),
                                  ),

                            const SizedBox(height: 3),
                            Text(
                              k.label,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget recentActivitySection(bool isDark) {
    return CardWidget(
      isDark: isDark,
      icon: Icons.timeline_rounded,
      iconColor: Colors.purple,
      title: 'Recent Activity',
      subtitle: 'Latest events across all modules',
      child: Obx(
        () => loading.value
            ? ShimmerList(isDark: isDark, pulseCtrl: pulseCtrl)
            : buildActivityTimeline(isDark),
      ),
    );
  }

  Widget buildActivityTimeline(bool isDark) {
    final activities = <Act>[];

    for (final l in recentLeaves.take(3)) {
      final status = l['status']?.toString() ?? 'pending';
      final color = status == 'approved'
          ? AppTheme.successColor
          : status == 'rejected'
          ? AppTheme.errorColor
          : AppTheme.warningColor;
      activities.add(
        Act(
          title: 'Leave Request - ${status.toUpperCase()}',
          sub: l['reason']?.toString().isNotEmpty == true
              ? l['reason'].toString()
              : 'No reason provided',
          icon: Icons.event_busy_rounded,
          color: color,
          time: timeAgo(l['created_at']?.toString()),
        ),
      );
    }

    // From attendance logs
    for (final a in recentAttendance.take(3)) {
      final type = a['punch_type']?.toString() ?? '';
      activities.add(
        Act(
          title: 'Attendance — Punch ${type.toUpperCase()}',
          sub:
              'Date: ${a['date']?.toString() ?? 'N/A'}  •  ${a['is_manual'] == true ? 'Manual Entry' : 'Auto'}',
          icon: Icons.fingerprint_rounded,
          color: type == 'in' ? AppTheme.successColor : AppTheme.errorColor,
          time: timeAgo(a['created_at']?.toString()),
        ),
      );
    }

    // From new users
    for (final u in recentUsers.take(2)) {
      activities.add(
        Act(
          title: 'New User — ${u['full_name'] ?? 'Unknown'}',
          sub: u['email']?.toString() ?? '',
          icon: Icons.person_add_rounded,
          color: const Color(0xFF3B82F6),
          time: timeAgo(u['created_at']?.toString()),
        ),
      );
    }

    // From payments
    for (final p in recentPayments.take(2)) {
      final status = p['status']?.toString() ?? '';
      activities.add(
        Act(
          title: 'Payment — ${status.toUpperCase()}',
          sub:
              '${p['currency'] ?? 'INR'} ${p['amount'] ?? 0}  •  ${p['gateway'] ?? 'N/A'}',
          icon: Icons.credit_card_rounded,
          color: status == 'success'
              ? AppTheme.successColor
              : AppTheme.warningColor,
          time: timeAgo(p['created_at']?.toString()),
        ),
      );
    }

    // Sort by recency (already sorted from DB)
    if (activities.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.inbox_rounded,
                size: 48,
                color: Colors.grey.withOpacity(0.3),
              ),
              const SizedBox(height: 12),
              Text(
                'No recent activity found',
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: activities.asMap().entries.map((e) {
        final i = e.key;
        final a = e.value;
        final isLast = i == activities.length - 1;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 250 + i * 60),
          curve: Curves.easeOut,
          builder: (_, v, child) => Opacity(opacity: v, child: child),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline
                Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: a.color.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(a.icon, color: a.color, size: 15),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 1.5,
                          margin: const EdgeInsets.symmetric(vertical: 3),
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                a.title,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1E293B),
                                ),
                              ),
                            ),
                            Text(
                              a.time,
                              style: TextStyle(
                                fontSize: 10.5,
                                color: isDark
                                    ? const Color(0xFF475569)
                                    : const Color(0xFFCBD5E1),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          a.sub,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark
                                ? const Color(0xFF64748B)
                                : const Color(0xFF94A3B8),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── HELPERS ────────────────────────────────────────────────────
  String timeAgo(String? ts) {
    if (ts == null || ts.isEmpty) return '—';
    try {
      final dt = DateTime.parse(ts).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inSeconds < 60) return 'just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '—';
    }
  }

  Widget chartsRow(bool isDark) {
    return LayoutBuilder(
      builder: (_, box) {
        final wide = box.maxWidth > 680;
        return wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: barChart(isDark)),
                  const SizedBox(width: 16),
                  Expanded(flex: 4, child: donutChart(isDark)),
                ],
              )
            : Column(
                children: [
                  barChart(isDark),
                  const SizedBox(height: 16),
                  donutChart(isDark),
                ],
              );
      },
    );
  }

  Widget bottomRow(bool isDark) {
    return LayoutBuilder(
      builder: (_, box) {
        final wide = box.maxWidth > 680;
        return wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: quickNav(isDark)),
                  const SizedBox(width: 16),
                  Expanded(flex: 3, child: summaryStats(isDark)),
                ],
              )
            : Column(
                children: [
                  summaryStats(isDark),
                  const SizedBox(height: 16),
                  quickNav(isDark),
                ],
              );
      },
    );
  }

  Widget quickNav(bool isDark) {
    final mods = [
      Mod(
        'Organizations',
        counts['organizations'] ?? 0,
        Icons.corporate_fare_rounded,
        const Color(0xFF3B82F6),
        AppRoutes.organizations,
      ),
      Mod(
        'Departments',
        counts['departments'] ?? 0,
        Icons.account_tree_rounded,
        const Color(0xFF8B5CF6),
        AppRoutes.departments,
      ),
      Mod(
        'Attendance',
        counts['attendance_logs'] ?? 0,
        Icons.fingerprint_rounded,
        const Color(0xFF10B981),
        AppRoutes.attendanceLogs,
      ),
      Mod(
        'Payments',
        counts['payments'] ?? 0,
        Icons.credit_card_rounded,
        const Color(0xFFF59E0B),
        AppRoutes.payments,
      ),
      Mod(
        'Holidays',
        counts['holidays'] ?? 0,
        Icons.celebration_rounded,
        const Color(0xFFEC4899),
        AppRoutes.holidays,
      ),
      Mod(
        'Salary Types',
        counts['salary_types'] ?? 0,
        Icons.payments_rounded,
        const Color(0xFF06B6D4),
        AppRoutes.salaryTypes,
      ),
    ];
    return CardWidget(
      isDark: isDark,
      icon: Icons.grid_view_rounded,
      iconColor: const Color(0xFF10B981),
      title: 'Quick Navigate',
      subtitle: 'Jump to any module',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: 2.1,
        ),
        itemCount: mods.length,
        itemBuilder: (_, i) {
          final m = mods[i];
          return InkWell(
            onTap: () {
              Get.find<AppController>().currentRoute.value = m.route;
              Get.toNamed(m.route);
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: m.color.withOpacity(0.07),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: m.color.withOpacity(0.18)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: m.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(m.icon, color: m.color, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Obx(
                          () => loading.value
                              ? ShimmerWidget(
                                  isDark: isDark,
                                  w: 24,
                                  h: 16,
                                  pulseCtrl: pulseCtrl,
                                )
                              : Text(
                                  '${m.count}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: m.color,
                                    height: 1.1,
                                  ),
                                ),
                        ),
                        Text(
                          m.label,
                          style: TextStyle(
                            fontSize: 9.5,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget summaryStats(bool isDark) {
    final items = [
      SummStat(
        'Total Roles',
        counts['roles'] ?? 0,
        Icons.manage_accounts_rounded,
        const Color(0xFFEC4899),
      ),
      SummStat(
        'Role Permissions',
        counts['role_permissions'] ?? 0,
        Icons.security_rounded,
        const Color(0xFF3B82F6),
      ),
      SummStat(
        'Salary Types',
        counts['salary_types'] ?? 0,
        Icons.payments_rounded,
        const Color(0xFF14B8A6),
      ),
      SummStat(
        'Holidays',
        counts['holidays'] ?? 0,
        Icons.celebration_rounded,
        const Color(0xFF8B5CF6),
      ),
      SummStat(
        'Sub Plans',
        counts['subscription_plans'] ?? 0,
        Icons.workspace_premium_rounded,
        const Color(0xFF06B6D4),
      ),
      SummStat(
        'Perm. Requests',
        counts['permission_requests'] ?? 0,
        Icons.lock_clock_rounded,
        const Color(0xFFF59E0B),
      ),
    ];
    return CardWidget(
      isDark: isDark,
      icon: Icons.analytics_rounded,
      iconColor: const Color(0xFFEC4899),
      title: "Module Summary",
      subtitle: "All table record counts",
      child: Column(
        children: items.map((s) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: s.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(s.icon, color: s.color, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    s.label,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                ),
                // Progress bar
                SizedBox(
                  width: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(
                        begin: 0,
                        end: s.count == 0
                            ? 0
                            : (s.count /
                                      (counts.values.fold(
                                        1,
                                        (a, b) => a > b ? a : b,
                                      )))
                                  .clamp(0.05, 1.0),
                      ),
                      duration: const Duration(milliseconds: 900),
                      builder: (_, v, _) => LinearProgressIndicator(
                        value: v,
                        backgroundColor: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation(s.color),
                        minHeight: 6,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 28,
                  child: Text(
                    '${s.count}',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: s.color,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget barChart(bool isDark) {
    final bars = [
      Bar('Orgs', counts['organizations'] ?? 0, const Color(0xFF3B82F6)),
      Bar('Cos', counts['companies'] ?? 0, const Color(0xFF10B981)),
      Bar('Depts', counts['departments'] ?? 0, const Color(0xFF8B5CF6)),
      Bar('Emps', counts['employees'] ?? 0, const Color(0xFFF59E0B)),
      Bar('Users', counts['users'] ?? 0, const Color(0xFFEF4444)),
      Bar('Roles', counts['roles'] ?? 0, const Color(0xFF06B6D4)),
      Bar('Leaves', counts['leave_requests'] ?? 0, const Color(0xFFEC4899)),
      Bar('Subs', counts['subscriptions'] ?? 0, const Color(0xFF14B8A6)),
    ];
    final maxVal = bars.fold(1, (m, b) => b.value > m ? b.value : m).toDouble();

    return CardWidget(
      isDark: isDark,
      icon: Icons.bar_chart_rounded,
      iconColor: const Color(0xFF3B82F6),
      title: 'Records Overview',
      subtitle: "All modules at a glance",
      child: SizedBox(
        height: 200,
        child: Obx(
          () => loading.value
              ? BarShimmer(isDark: isDark, pulseCtrl: pulseCtrl)
              : Column(
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: bars.map((b) {
                          final frac = b.value / maxVal;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    '${b.value}',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: b.color,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0, end: frac),
                                    duration: const Duration(milliseconds: 900),
                                    curve: Curves.elasticOut,
                                    builder: (_, v, _) => Container(
                                      height: (155 * v).clamp(4.0, 155.0),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            b.color,
                                            b.color.withOpacity(0.4),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(6),
                                            ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: b.color.withOpacity(0.3),
                                            blurRadius: 6,
                                            offset: const Offset(0, -2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: bars
                          .map(
                            (b) => Expanded(
                              child: Text(
                                b.label,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  color: isDark
                                      ? const Color(0xFF64748B)
                                      : const Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget donutChart(bool isDark) {
    final allSegs = [
      Seg('Employees', counts['employees'] ?? 0, const Color(0xFF3B82F6)),
      Seg('Users', counts['users'] ?? 0, const Color(0xFF10B981)),
      Seg('Departments', counts['departments'] ?? 0, const Color(0xFF8B5CF6)),
      Seg('Roles', counts['roles'] ?? 0, const Color(0xFFF59E0B)),
      Seg(
        'Subscriptions',
        counts['subscriptions'] ?? 0,
        const Color(0xFFEF4444),
      ),
      Seg(
        'Others',
        (counts['holidays'] ?? 0) +
            (counts['salary_types'] ?? 0) +
            (counts['permission_requests'] ?? 0),
        const Color(0xFF06B6D4),
      ),
    ];
    final segs = allSegs.where((s) => s.value > 0).toList();
    final total = segs.fold(0, (s, e) => s + e.value);
    return CardWidget(
      isDark: isDark,
      icon: Icons.donut_large_rounded,
      iconColor: const Color(0xFF8B5CF6),
      title: 'Data Distribution',
      subtitle: 'By category breakdown',
      child: Obx(
        () => loading.value
            ? BarShimmer(isDark: isDark, pulseCtrl: pulseCtrl)
            : total == 0
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.donut_large_rounded,
                        size: 48,
                        color: Colors.grey.withOpacity(0.3),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'No data yet',
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF64748B)
                              : const Color(0xFF94A3B8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Column(
                children: [
                  // Donut ring built from widgets
                  SizedBox(
                    height: 180,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left: donut widget
                        Expanded(
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 1100),
                            curve: Curves.easeInOut,
                            builder: (ctx, progress, __) {
                              return LayoutBuilder(
                                builder: (ctx, box) {
                                  final sz = math.min(box.maxWidth, 160.0);
                                  return SizedBox(
                                    width: sz,
                                    height: sz,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Donut ring via CustomPaint with explicit size
                                        SizedBox(
                                          width: sz,
                                          height: sz,
                                          child: CustomPaint(
                                            painter: DonutPainter(
                                              segs: segs,
                                              total: total.toDouble(),
                                              progress: progress,
                                              isDark: isDark,
                                            ),
                                          ),
                                        ),
                                        // Center text
                                        if (progress > 0.7)
                                          Opacity(
                                            opacity: ((progress - 0.7) / 0.3)
                                                .clamp(0, 1),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  '$total',
                                                  style: TextStyle(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.w900,
                                                    color: isDark
                                                        ? Colors.white
                                                        : const Color(
                                                            0xFF1E293B,
                                                          ),
                                                    height: 1,
                                                  ),
                                                ),
                                                Text(
                                                  'records',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: isDark
                                                        ? const Color(
                                                            0xFF64748B,
                                                          )
                                                        : const Color(
                                                            0xFF94A3B8,
                                                          ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Right: legend
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: segs.map((s) {
                              final pct = total == 0
                                  ? 0.0
                                  : s.value / total * 100;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 9),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: s.color,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    const SizedBox(width: 7),
                                    Expanded(
                                      child: Text(
                                        s.label,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark
                                              ? const Color(0xFF94A3B8)
                                              : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${pct.toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: s.color,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '(${s.value})',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isDark
                                            ? const Color(0xFF475569)
                                            : const Color(0xFFCBD5E1),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Stacked bar as additional visual
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      height: 8,
                      child: Row(
                        children: segs.map((s) {
                          final flex = s.value;
                          return Expanded(
                            flex: flex > 0 ? flex : 1,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 900),
                              builder: (_, v, _) => FractionallySizedBox(
                                widthFactor: v,
                                alignment: Alignment.centerLeft,
                                child: Container(color: s.color),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Total badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.circle,
                          size: 7,
                          color: Color(0xFF3B82F6),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'Total Records: $total',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
