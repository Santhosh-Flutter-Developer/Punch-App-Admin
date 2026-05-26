import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sri_hr_admin/presentation/dashboard/controller/dashboard_controller.dart';
import 'package:sri_hr_admin/services/supabase_service.dart';
import 'package:sri_hr_admin/widgets/main_layout.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  final controller = Get.isRegistered<DashboardController>()
      ? Get.find<DashboardController>()
      : Get.put(DashboardController());
  Map<String, int> _counts = {};
  List<Map<String, dynamic>> recentLeaves = [];
  List<Map<String, dynamic>> recentAttendance = [];
  List<Map<String, dynamic>> recentUsers = [];
  List<Map<String, dynamic>> recentPayments = [];
  bool loading = true;
  String? error;

  // Animation
  late AnimationController pulseCtrl;
  late AnimationController fadeCtrl;
  late Animation<double> fadeAnim;

  // Filter
  String selectedPeriod = 'All Time';
  final periods = ['All Time', 'Today', 'This Week', 'This Month'];

  @override
  void initState() {
    super.initState();
    pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    fadeAnim = CurvedAnimation(parent: fadeCtrl, curve: Curves.easeOut);
    load();
  }

  @override
  void dispose() {
    pulseCtrl.dispose();
    fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
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

      // Load all counts + recent activity in parallel
      final results = await Future.wait([
        ...tables.map((t) => SupabaseService.fetchAll(t)),
        // Recent activity queries
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

      final counts = <String, int>{};
      for (int i = 0; i < tables.length; i++) {
        counts[tables[i]] = (results[i] as List).length;
      }

      setState(() {
        _counts = counts;
        recentLeaves = List<Map<String, dynamic>>.from(
          results[tables.length] as List,
        );
        recentAttendance = List<Map<String, dynamic>>.from(
          results[tables.length + 1] as List,
        );
        recentUsers = List<Map<String, dynamic>>.from(
          results[tables.length + 2] as List,
        );
        recentPayments = List<Map<String, dynamic>>.from(
          results[tables.length + 3] as List,
        );
        loading = false;
      });
      fadeCtrl.forward(from: 0);
    } catch (e) {
      setState(() {
        loading = false;
        error = e.toString();
      });
      debugPrint('Dashboard load error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MainLayout(
      title: 'Dashboard',
      actions: [
        isWide
            ?
              // Refresh
              TextButton.icon(
                onPressed: load,
                icon: const Icon(Icons.refresh_rounded, size: 15),
                label: const Text('Refresh', style: TextStyle(fontSize: 13)),
              )
            : IconButton(onPressed: load, icon: Icon(Icons.refresh_rounded)),
      ],
      child: error != null
          ? controller.buildError(onpressed: load, error: error)
          : FadeTransition(
              opacity: loading ? const AlwaysStoppedAnimation(1) : fadeAnim,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isWide ? 20.0 : 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    controller.heroBanner(
                      isDark,
                      isWide,
                      counts: _counts,
                      pulseCtrl: pulseCtrl,
                    ),
                    const SizedBox(height: 20),
                    controller.kpiRow(
                      isDark,
                      counts: _counts,
                      recentLeaves: recentLeaves,
                      pulseCtrl: pulseCtrl,
                      loading: loading,
                    ),
                    const SizedBox(height: 20),
                    controller.chartsRow(
                      isDark,
                      counts: _counts,
                      loading: loading,
                      pulseCtrl: pulseCtrl,
                    ),
                    const SizedBox(height: 20),
                    controller.bottomRow(
                      isDark,
                      counts: _counts,
                      loading: loading,
                      pulseCtrl: pulseCtrl,
                    ),
                    const SizedBox(height: 20),
                    controller.recentActivitySection(
                      isDark,
                      loading: loading,
                      pulseCtrl: pulseCtrl,
                      recentLeaves: recentLeaves,
                      recentAttendance: recentAttendance,
                      recentPayments: recentPayments,
                      recentUsers: recentUsers,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
