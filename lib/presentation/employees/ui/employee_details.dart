import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:punch_app_admin/core/theme/app_theme.dart';
import 'package:punch_app_admin/presentation/employees/widgets/app_avatar.dart';
import 'package:punch_app_admin/widgets/main_layout.dart';

class EmployeeDetail extends StatefulWidget {
  final Map<String, dynamic> employee;
  const EmployeeDetail({super.key, required this.employee});

  @override
  State<EmployeeDetail> createState() => _EmployeeDetailState();
}

class _EmployeeDetailState extends State<EmployeeDetail> {
  int _step = 0;

  static const _stepTitles = [
    'Basic Info',
    'Address',
    'Work & Role',
    'Login & Docs',
  ];
  static const _stepIcons = [
    Icons.person_rounded,
    Icons.location_on_rounded,
    Icons.work_rounded,
    Icons.lock_rounded,
  ];

  String _v(dynamic val) {
    if (val == null) return '';
    final s = val.toString().trim();
    if (s.isEmpty || s.toLowerCase() == 'null' || s == 'NULL' || s == 'EMPTY') {
      return '';
    }
    return s;
  }

  String _date(dynamic iso) {
    if (iso == null || iso.toString().trim().isEmpty) return '';
    try {
      return DateTime.parse(iso.toString()).toIso8601String().substring(0, 10);
    } catch (_) {
      return iso.toString();
    }
  }

  bool _bool(dynamic val) {
    if (val == null) return false;
    if (val is bool) return val;
    return val.toString().toLowerCase() == 'true';
  }

  // Exact same logic as user app initState document loading
  List<Map<String, dynamic>> _parseDocs() {
    final e = widget.employee;
    final List<Map<String, dynamic>> docs = [];

    final otherDocUrl = e['other_doc_url'];
    final aadharDocUrl = e['aadhar_doc_url'];

    if (otherDocUrl != null && otherDocUrl.toString().trim().isNotEmpty) {
      // Supabase may return it already decoded as a List
      if (otherDocUrl is List) {
        for (final item in otherDocUrl) {
          if (item is Map) {
            docs.add({
              'name': (item['name'] as String?) ?? 'document',
              'url': (item['url'] as String?) ?? '',
            });
          }
        }
        return docs;
      }
      // It's a JSON string — decode it exactly like user app
      try {
        final decoded = jsonDecode(otherDocUrl.toString()) as List<dynamic>;
        for (final item in decoded) {
          final m = item as Map<String, dynamic>;
          docs.add({
            'name': (m['name'] as String?) ?? 'document',
            'url': (m['url'] as String?) ?? '',
          });
        }
        return docs;
      } catch (_) {
        // Legacy: plain URL string
        final uri = Uri.tryParse(otherDocUrl.toString());
        final fileName = uri?.pathSegments.isNotEmpty == true
            ? Uri.decodeFull(uri!.pathSegments.last)
            : 'document';
        docs.add({'name': fileName, 'url': otherDocUrl.toString()});
        return docs;
      }
    }

    // Fallback: aadhar_doc_url (legacy)
    if (aadharDocUrl != null && aadharDocUrl.toString().trim().isNotEmpty) {
      final uri = Uri.tryParse(aadharDocUrl.toString());
      final fileName = uri?.pathSegments.isNotEmpty == true
          ? Uri.decodeFull(uri!.pathSegments.last)
          : 'document';
      docs.add({'name': fileName, 'url': aadharDocUrl.toString()});
    }

    return docs;
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 800;
    final e = widget.employee;

    return isWide
        ? MainLayout(
            title: 'View Employee',
            child: formWidget(e, isWide), // Scaffold
          )
        : formWidget(e, isWide); // MainLayout
  }

  Widget formWidget(Map<String, dynamic> e, bool isWide) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          _StepHeader(
            currentStep: _step,
            titles: _stepTitles,
            icons: _stepIcons,
            onTap: (i) => setState(() => _step = i),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: KeyedSubtree(
                key: ValueKey(_step),
                child: _buildStep(_step, e, isWide),
              ),
            ),
          ),
          _StepFooter(
            currentStep: _step,
            totalSteps: _stepTitles.length,
            onBack: () {
              if (_step > 0) {
                setState(() => _step--);
              } else {
                Navigator.of(context).pop();
              }
            },
            onNext: () {
              if (_step < _stepTitles.length - 1) {
                setState(() => _step++);
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep(int step, Map<String, dynamic> e, bool isWide) {
    switch (step) {
      case 0:
        return _StepBasic(e: e, v: _v, d: _date, isWide: isWide);
      case 1:
        return _StepAddress(e: e, v: _v, isWide: isWide);
      case 2:
        return _StepWork(e: e, v: _v, b: _bool, isWide: isWide);
      case 3:
        return _StepLoginDocs(e: e, v: _v, docs: _parseDocs());
      default:
        return const SizedBox();
    }
  }
}

// ─────────────────────────────────────────────────────────────────
// STEP HEADER
// ─────────────────────────────────────────────────────────────────
class _StepHeader extends StatelessWidget {
  final int currentStep;
  final List<String> titles;
  final List<IconData> icons;
  final void Function(int) onTap;

  const _StepHeader({
    required this.currentStep,
    required this.titles,
    required this.icons,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 800;
    return Container(
      color: AppTheme.primaryColor,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Back',
              ),
              SizedBox(width: 8),
              if(!isWide)
              Text(
                'View Employee',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: List.generate(titles.length, (i) {
              final isDone = i < currentStep;
              final isCurrent = i == currentStep;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDone
                                    ? AppTheme.accentGreen
                                    : isCurrent
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.2),
                                border: Border.all(
                                  color: isCurrent
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                boxShadow: isCurrent
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Center(
                                child: isDone
                                    ? const Icon(
                                        Icons.check_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      )
                                    : Icon(
                                        icons[i],
                                        color: isCurrent
                                            ? AppTheme.primaryColor
                                            : Colors.white,
                                        size: 18,
                                      ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              titles[i],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isCurrent || isDone
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.55),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (i < titles.length - 1)
                        Expanded(
                          child: Container(
                            height: 2,
                            margin: const EdgeInsets.only(bottom: 22),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1),
                              gradient: LinearGradient(
                                colors: [
                                  isDone
                                      ? AppTheme.accentGreen
                                      : Colors.white.withOpacity(0.3),
                                  i + 1 <= currentStep
                                      ? AppTheme.accentGreen
                                      : Colors.white.withOpacity(0.3),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// STEP FOOTER
// ─────────────────────────────────────────────────────────────────
class _StepFooter extends StatelessWidget {
  final int currentStep, totalSteps;
  final VoidCallback onBack, onNext;

  const _StepFooter({
    required this.currentStep,
    required this.totalSteps,
    required this.onBack,
    required this.onNext,
  });

  bool get isLast => currentStep == totalSteps - 1;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 800;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, size: 16),
            label: Padding(
              padding: EdgeInsets.symmetric(vertical: isWide ? 4.0 : 0.0),
              child: Text(currentStep == 0 ? 'Cancel' : 'Back'),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                totalSteps,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == currentStep ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: i <= currentStep
                        ? AppTheme.primaryColor
                        : AppTheme.border,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: onNext,
            icon: Icon(
              isLast ? Icons.close_rounded : Icons.arrow_forward_rounded,
              size: 16,
            ),
            label: Padding(
              padding: EdgeInsets.symmetric(vertical: isWide ? 4.0 : 0.0),
              child: Text(isLast ? 'Close' : 'Next'),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: isLast
                  ? AppTheme.accentGreen
                  : AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// STEP 1 — BASIC INFO
// ─────────────────────────────────────────────────────────────────
class _StepBasic extends StatelessWidget {
  final Map<String, dynamic> e;
  final String Function(dynamic) v;
  final String Function(dynamic) d;
  final bool isWide;

  const _StepBasic({
    required this.e,
    required this.v,
    required this.d,
    required this.isWide,
  });

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(isWide ? 20 : 12, 24, isWide ? 20 : 12, 8),
      child: Column(
        children: [
          // Avatar
          Center(
            child: Stack(
              children: [
                AppAvatar(
                  imageUrl: v(e['profile_picture']).isEmpty
                      ? null
                      : v(e['profile_picture']),
                  name: v(e['full_name']).isEmpty ? 'E' : v(e['full_name']),
                  size: 80,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 14,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _SectionCard(
            title: 'Employee Information',
            icon: Icons.badge_rounded,
            children: [
              _TwoCol(
                isWide: isWide,
                left: _RF(
                  'Employee Code *',
                  Icons.tag_rounded,
                  v(e['employee_code']),
                ),
                right: _RF(
                  'Full Name *',
                  Icons.person_rounded,
                  v(e['full_name']),
                ),
              ),
              const SizedBox(height: 16),
              _TwoCol(
                isWide: isWide,
                left: _RF(
                  'Date of Joining',
                  Icons.calendar_today_rounded,
                  d(e['doj']),
                ),
                right: _RF('Date of Birth *', Icons.cake_rounded, d(e['dob'])),
              ),
              const SizedBox(height: 16),
              _TwoCol(
                isWide: isWide,
                left: _RF(
                  'Gender',
                  Icons.wc_rounded,
                  _cap(v(e['gender'])),
                  isDropdown: true,
                ),
                right: _RF(
                  'Father / Husband Name',
                  Icons.people_rounded,
                  v(e['father_husband_name']),
                ),
              ),
              const SizedBox(height: 16),
              _TwoCol(
                isWide: isWide,
                left: _RF(
                  'Mobile Number *',
                  Icons.phone_rounded,
                  v(e['mobile']),
                  suffix: v(e['mobile']).isNotEmpty
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppTheme.accentGreen,
                          size: 18,
                        )
                      : null,
                ),
                right: _RF(
                  'Email Address *',
                  Icons.email_outlined,
                  v(e['email']),
                  suffix: v(e['email']).isNotEmpty
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppTheme.accentGreen,
                          size: 18,
                        )
                      : null,
                ),
              ),
              if (v(e['mobile']).isNotEmpty) ...[
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${v(e['mobile']).length}/10',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Status',
            icon: Icons.toggle_on_rounded,
            children: [
              _RF(
                'Employee Status',
                Icons.toggle_on_rounded,
                e['employee_statuses'] != null
                    ? v(e['employee_statuses']['name'])
                    : '',
                isDropdown: true,
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// STEP 2 — ADDRESS
// ─────────────────────────────────────────────────────────────────
class _StepAddress extends StatelessWidget {
  final Map<String, dynamic> e;
  final String Function(dynamic) v;
  final bool isWide;

  const _StepAddress({required this.e, required this.v, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final addr = v(e['address']);
    final aadhar = v(e['aadhar_address']);
    final same = addr.isNotEmpty && addr == aadhar;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(isWide ? 20 : 12, 24, isWide ? 20 : 12, 8),
      child: Column(
        children: [
          _SectionCard(
            title: 'Residential Address',
            icon: Icons.home_rounded,
            children: [
              _RF('Full Address', Icons.home_outlined, addr, maxLines: 3),
              const SizedBox(height: 16),
              _TwoCol(
                isWide: isWide,
                left: _RF('Country', Icons.flag_rounded, v(e['country'])),
                right: _RF('State', Icons.map_rounded, v(e['state'])),
              ),
              const SizedBox(height: 16),
              _TwoCol(
                isWide: isWide,
                left: _RF('City', Icons.location_city_rounded, v(e['city'])),
                right: _RF('Pincode', Icons.pin_drop_rounded, v(e['pincode'])),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Aadhar Address',
            icon: Icons.credit_card_rounded,
            children: [
              // Same as Full Address checkbox
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: same ? AppTheme.primaryColor : Colors.transparent,
                      border: Border.all(color: AppTheme.border, width: 1.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: same
                        ? const Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Same as Full Address',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _RF(
                'Aadhar Registered Address',
                Icons.credit_card_outlined,
                aadhar,
                maxLines: 3,
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// STEP 3 — WORK & ROLE
// ─────────────────────────────────────────────────────────────────
class _StepWork extends StatelessWidget {
  final Map<String, dynamic> e;
  final String Function(dynamic) v;
  final bool Function(dynamic) b;
  final bool isWide;

  const _StepWork({
    required this.e,
    required this.v,
    required this.b,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    final company = e['companies'];

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(isWide ? 20 : 12, 24, isWide ? 20 : 12, 8),
      child: Column(
        children: [
          _SectionCard(
            title: 'Company',
            icon: Icons.business_rounded,
            children: [
              _RF(
                'Company / Branch *',
                Icons.business_rounded,
                company != null ? v(company['name']) : '',
                isDropdown: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Work Settings',
            icon: Icons.tune_rounded,
            children: [
              _RF(
                'Casual Leave (days/year)',
                Icons.event_busy_rounded,
                '${e['casual_leave'] ?? 12}',
              ),
              const SizedBox(height: 16),
              _ToggleRow(
                icon: Icons.phone_android_rounded,
                label: 'Mobile Login Allowed',
                subtitle: 'Can login via mobile app',
                value: b(e['mobile_login']),
              ),
              const SizedBox(height: 10),
              _ToggleRow(
                icon: Icons.location_off_rounded,
                label: 'Outside Office Allowed',
                subtitle: 'Can mark attendance outside office',
                value: b(e['outside_office']),
              ),
              const SizedBox(height: 10),
              _ToggleRow(
                icon: Icons.check_circle_rounded,
                label: 'Active Employee',
                subtitle: 'Inactive employees cannot login',
                value: b(e['is_active']),
                color: AppTheme.accentGreen,
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// STEP 4 — LOGIN & DOCS
// ─────────────────────────────────────────────────────────────────
class _StepLoginDocs extends StatelessWidget {
  final Map<String, dynamic> e;
  final String Function(dynamic) v;
  final List<Map<String, dynamic>> docs;

  const _StepLoginDocs({required this.e, required this.v, required this.docs});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 800;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(isWide ? 20 : 12, 24, isWide ? 20 : 12, 8),
      child: Column(
        children: [
          _SectionCard(
            title: 'Login Credentials',
            icon: Icons.lock_rounded,
            children: [
              _RF(
                'Username',
                Icons.person_outline_rounded,
                v(e['employee_code']),
                hint: 'Username',
              ),
              const SizedBox(height: 16),
              // Password — always empty in view mode (not stored)
              _RF(
                'Password',
                Icons.lock_outline_rounded,
                '',
                hint: 'Leave blank for no login access',
                showVisibilityIcon: true,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.info.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.info.withOpacity(0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: AppTheme.info,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Username defaults to Employee Code. Employee can login with username or email.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Documents',
            icon: Icons.attach_file_rounded,
            trailing: TextButton.icon(
              onPressed: null,
              icon: const Icon(Icons.upload_file_rounded, size: 16),
              label: const Text('Attach File'),
            ),
            children: docs.isEmpty
                ? [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.folder_open_rounded,
                                size: 28,
                                color: AppTheme.textMuted,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'No documents attached',
                              style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'PDF, JPG, PNG, DOC supported',
                              style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]
                : docs.map((doc) {
                    final name = (doc['name'] as String?) ?? 'document';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGreen.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppTheme.accentGreen.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppTheme.accentGreen.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.cloud_done_rounded,
                              color: AppTheme.accentGreen,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Text(
                                  'Already uploaded',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.accentGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.04),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              border: const Border(bottom: BorderSide(color: AppTheme.border)),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppTheme.primaryColor, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (trailing != null) ...[const Spacer(), trailing!],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

// Two-column layout helper
class _TwoCol extends StatelessWidget {
  final bool isWide;
  final Widget left, right;
  const _TwoCol({
    required this.isWide,
    required this.left,
    required this.right,
  });

  @override
  Widget build(BuildContext context) {
    if (!isWide) {
      return Column(children: [left, const SizedBox(height: 16), right]);
    }
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 16),
        Expanded(child: right),
      ],
    );
  }
}

// Read-only field — _RF
Widget _RF(
  String label,
  IconData icon,
  String value, {
  String? hint,
  bool isDropdown = false,
  bool showVisibilityIcon = false,
  Widget? suffix,
  int maxLines = 1,
}) {
  final isEmpty = value.isEmpty;
  final display = isEmpty ? (hint ?? '') : value;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppTheme.textSecondary,
        ),
      ),
      const SizedBox(height: 6),
      Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: maxLines > 1 ? 12 : 14,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          crossAxisAlignment: maxLines > 1
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppTheme.textTertiary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                display,
                maxLines: maxLines,
                overflow: maxLines > 1
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: isEmpty ? AppTheme.textTertiary : AppTheme.textPrimary,
                ),
              ),
            ),
            if (suffix != null) suffix,
            if (showVisibilityIcon)
              const Icon(
                Icons.visibility_off_outlined,
                size: 18,
                color: AppTheme.textTertiary,
              ),
            if (isDropdown && suffix == null && !showVisibilityIcon)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isEmpty)
                    const Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: AppTheme.textTertiary,
                    ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.search_rounded,
                    size: 16,
                    color: AppTheme.textTertiary,
                  ),
                ],
              ),
          ],
        ),
      ),
    ],
  );
}

// Toggle row
class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label, subtitle;
  final bool value;
  final Color color;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    this.color = AppTheme.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: value ? color.withOpacity(0.05) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? color.withOpacity(0.25) : AppTheme.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: value
                  ? color.withOpacity(0.12)
                  : AppTheme.border.withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: value ? color : AppTheme.textMuted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          IgnorePointer(
            child: Switch(
              value: value,
              onChanged: (_) {},
              activeColor: color,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}
