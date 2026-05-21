import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sri_hr_admin/presentation/dashboard/controller/dashboard_controller.dart';
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

  @override
  void initState() {
    super.initState();
    controller.pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    controller.fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    controller.fadeAnim = CurvedAnimation(
      parent: controller.fadeCtrl,
      curve: Curves.easeOut,
    );

    controller.load();
  }

  @override
  void dispose() {
    controller.pulseCtrl.dispose();
    controller.fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MainLayout(
      title: 'Dashboard',
      actions: [
        // Refresh
        TextButton.icon(
          onPressed: controller.load,
          icon: const Icon(Icons.refresh_rounded, size: 15),
          label: const Text('Refresh', style: TextStyle(fontSize: 13)),
        ),
      ],
      child: controller.error != null
          ? controller.buildError()
          : FadeTransition(
              opacity: controller.loading.value
                  ? const AlwaysStoppedAnimation(1)
                  : controller.fadeAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    controller.heroBanner(isDark),
                    const SizedBox(height: 20),
                    controller.kpiRow(isDark),
                    const SizedBox(height: 20),
                    controller.chartsRow(isDark),
                     const SizedBox(height: 20),
                    controller.bottomRow(isDark),
                     const SizedBox(height: 20),
                    controller.recentActivitySection(isDark),
                  ],
                ),
              ),
            ),
    );
  }
}
