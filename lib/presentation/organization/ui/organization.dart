import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sri_hr_admin/presentation/organization/controller/organization_controller.dart';
import 'package:sri_hr_admin/services/supabase_service.dart';
import 'package:sri_hr_admin/widgets/main_layout.dart';

class Organization extends StatefulWidget {
  const Organization({super.key});

  @override
  State<Organization> createState() => _OrganizationState();
}

class _OrganizationState extends State<Organization>
    with TickerProviderStateMixin {
  final controller = Get.isRegistered<OrganizationController>()
      ? Get.find<OrganizationController>()
      : Get.put(OrganizationController());

  List<Map<String, dynamic>> _orgs = [];
  List<Map<String, dynamic>> _companies = [];
  List<Map<String, dynamic>> filtered = [];
  bool loading = true;
  bool isGrid = true;
  String search = '';
  late TabController tabCtrl;
  int selectedOrgIdx = 0; // -1 = All

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    tabCtrl.dispose();
    super.dispose();
  }

  Future<void> load() async {
    setState(() => loading = true);
    try {
      final results = await Future.wait([
        SupabaseService.fetchAll('organizations'),
        SupabaseService.fetchAll('companies'),
      ]);
      final orgs = List<Map<String, dynamic>>.from(results[0]);
      final companies = List<Map<String, dynamic>>.from(results[1]);
      setState(() {
        _orgs = orgs;
        _companies = companies;
        filtered = orgs;
        tabCtrl = TabController(length: orgs.length + 1, vsync: this);
        tabCtrl.addListener(() {
          if (!tabCtrl.indexIsChanging) {
            setState(() => selectedOrgIdx = tabCtrl.index);
          }
        });
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  void applySearch(String q) {
    search = q;
    setState(() {
      filtered = q.isEmpty
          ? _orgs
          : _orgs
                .where(
                  (o) => o.values.any(
                    (v) =>
                        v?.toString().toLowerCase().contains(q.toLowerCase()) ??
                        false,
                  ),
                )
                .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MainLayout(
      title: 'Organizations',
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // ── Top toolbar ───────────────────────────────────
                controller.buildToolbar(
                  isDark,
                  onChanged: applySearch,
                  isGrid: isGrid,
                  onTap: () => setState(() => isGrid = !isGrid),
                  onSave: (data) async {
                    await SupabaseService.insert('organizations', data);
                    await load();
                  },
                  onRefresh: load,
                  orgs: _orgs,
                ),
                // ── Org tabs ──────────────────────────────────────
                if (_orgs.isNotEmpty)
                  controller.buildOrgTabs(
                    isDark,
                    tabCtrl: tabCtrl,
                    orgs: _orgs,
                  ),
                // ── Content ───────────────────────────────────────
                Expanded(
                  child: controller.buildContent(
                    isDark,
                    search: search,
                    filtered: filtered,
                    selectedOrgIdx: selectedOrgIdx,
                    orgs: _orgs,
                    onSave: (data) async {
                      await SupabaseService.insert('organizations', data);
                      await load();
                    },
                    onPressed: () async {
                      await load();
                    },
                    isGrid: isGrid,
                    companies: _companies,
                  ),
                ),
              ],
            ),
    );
  }
}
