import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:sri_hr_admin/core/theme/app_theme.dart';
import 'package:sri_hr_admin/presentation/companies/controller/company_controller.dart';
import 'package:sri_hr_admin/presentation/companies/widgets/sri_detail_card.dart';
import 'package:sri_hr_admin/widgets/sri_textfield.dart';

class CompanyDetails extends StatefulWidget {
  final Map<String, dynamic> company;
  final CompanyController controller;
  const CompanyDetails({
    super.key,
    required this.company,
    required this.controller,
  });

  @override
  State<CompanyDetails> createState() => _CompanyDetailsState();
}

class _CompanyDetailsState extends State<CompanyDetails> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController name,
      phone,
      email,
      address,
      country,
      state,
      city,
      pincode,
      gstin,
      branchCode,
      lat,
      lon,
      radius;
  bool editing = false;
  Uint8List? logoBytes;
  String? logoPath;

  @override
  void initState() {
    super.initState();
    init(widget.company);
  }

  void init(Map<String, dynamic> c) {
    name = TextEditingController(text: c['name'] ?? '');
    phone = TextEditingController(text: c["phone"] ?? '');
    email = TextEditingController(text: c["email"] ?? '');
    address = TextEditingController(text: c["address"] ?? '');
    country = TextEditingController(text: c["country"] ?? '');
    state = TextEditingController(text: c["state"] ?? '');
    city = TextEditingController(text: c["city"] ?? '');
    pincode = TextEditingController(text: c["pincode"] ?? '');
    gstin = TextEditingController(text: c["gstin"] ?? '');
    branchCode = TextEditingController(text: c["branch_code"] ?? '');
    lat = TextEditingController(text: '${c["latitude"] ?? ''}');
    lon = TextEditingController(text: '${c["longitude"] ?? ''}');
    radius = TextEditingController(text: '${c["radius"] ?? 100}');
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 800;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isWide ? 24.0 : 10.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isWide)
                InkWell(
                  onTap: () {
                    widget.controller.enable.value = false;
                    widget.controller.enable.refresh();
                  },
                  child: const Icon(Icons.arrow_back_ios_rounded),
                  // padding: EdgeInsets.zero,
                ),
              const SizedBox(height: 20.0),
              headerCard(),
              const SizedBox(height: 20.0),
              SriDetailCard(
                title: 'Basic Information',
                icon: Icons.info_outline_rounded,
                children: [
                  ResponsiveGridRow(
                    children: [
                      ResponsiveGridCol(
                        xl: 6,
                        lg: 6,
                        md: 6,
                        xs: 12,
                        sm: 12,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: 20.0,
                            right: isWide ? 8.0 : 0.0,
                          ),
                          child: SriTextField(
                            controller: name,
                            label: 'Company Name *',
                            labelColor: AppTheme.textPrimary,
                            borderColor: AppTheme.border,
                            iconColor: AppTheme.textMuted,
                            textColor: AppTheme.textPrimary,
                            fillColor: AppTheme.surfaceVariant,
                            readOnly: !editing,
                            prefixIcon: Icons.business_rounded,
                            validator: (v) =>
                                v?.isEmpty == true ? 'Required' : null,
                          ),
                        ),
                      ),
                      ResponsiveGridCol(
                        xl: 6,
                        lg: 6,
                        md: 6,
                        xs: 12,
                        sm: 12,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: 20.0,
                            left: isWide ? 8.0 : 0.0,
                          ),
                          child: SriTextField(
                            controller: branchCode,
                            label: 'Branch Code',
                            labelColor: AppTheme.textPrimary,
                            borderColor: AppTheme.border,
                            iconColor: AppTheme.textMuted,
                            textColor: AppTheme.textPrimary,
                            fillColor: AppTheme.surfaceVariant,
                            readOnly: !editing,
                            prefixIcon: Icons.tag_rounded,
                          ),
                        ),
                      ),
                      ResponsiveGridCol(
                        xl: 6,
                        lg: 6,
                        md: 6,
                        xs: 12,
                        sm: 12,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: 20.0,
                            right: isWide ? 8.0 : 0.0,
                          ),
                          child: SriTextField(
                            controller: phone,
                            label: 'Phone',
                            readOnly: !editing,
                            labelColor: AppTheme.textPrimary,
                            borderColor: AppTheme.border,
                            iconColor: AppTheme.textMuted,
                            textColor: AppTheme.textPrimary,
                            fillColor: AppTheme.surfaceVariant,
                            keyboardType: TextInputType.phone,
                            prefixIcon: Icons.phone_rounded,
                          ),
                        ),
                      ),
                      ResponsiveGridCol(
                        xl: 6,
                        lg: 6,
                        md: 6,
                        xs: 12,
                        sm: 12,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: 20.0,
                            left: isWide ? 8.0 : 0.0,
                          ),
                          child: SriTextField(
                            controller: email,
                            label: 'Email',
                            readOnly: !editing,
                            labelColor: AppTheme.textPrimary,
                            borderColor: AppTheme.border,
                            iconColor: AppTheme.textMuted,
                            textColor: AppTheme.textPrimary,
                            fillColor: AppTheme.surfaceVariant,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                          ),
                        ),
                      ),
                      ResponsiveGridCol(
                        xl: 6,
                        lg: 6,
                        md: 6,
                        xs: 12,
                        sm: 12,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: 20.0,
                            right: isWide ? 8.0 : 0.0,
                          ),
                          child: SriTextField(
                            controller: gstin,
                            label: 'GSTIN',
                            labelColor: AppTheme.textPrimary,
                            borderColor: AppTheme.border,
                            iconColor: AppTheme.textMuted,
                            textColor: AppTheme.textPrimary,
                            fillColor: AppTheme.surfaceVariant,
                            readOnly: !editing,
                            prefixIcon: Icons.numbers_rounded,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // ── Address ──────────────────────────────────
              SriDetailCard(
                title: 'Address',
                icon: Icons.location_on_rounded,
                children: [
                  ResponsiveGridRow(
                    children: [
                      ResponsiveGridCol(
                        xl: 12,
                        lg: 12,
                        md: 12,
                        xs: 12,
                        sm: 12,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: SriTextField(
                            controller: address,
                            label: 'Full Address',
                            readOnly: !editing,
                            labelColor: AppTheme.textPrimary,
                            borderColor: AppTheme.border,
                            iconColor: AppTheme.textMuted,
                            textColor: AppTheme.textPrimary,
                            fillColor: AppTheme.surfaceVariant,
                            maxLines: 2,
                            prefixIcon: Icons.home_rounded,
                          ),
                        ),
                      ),
                      ResponsiveGridCol(
                        xl: 6,
                        lg: 6,
                        md: 6,
                        xs: 12,
                        sm: 12,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: 20.0,
                            right: isWide ? 8.0 : 0.0,
                          ),
                          child: SriTextField(
                            controller: country,
                            label: 'Country',
                            labelColor: AppTheme.textPrimary,
                            borderColor: AppTheme.border,
                            iconColor: AppTheme.textMuted,
                            textColor: AppTheme.textPrimary,
                            fillColor: AppTheme.surfaceVariant,
                            readOnly: !editing,
                            prefixIcon: Icons.flag_rounded,
                          ),
                        ),
                      ),
                      ResponsiveGridCol(
                        xl: 6,
                        lg: 6,
                        md: 6,
                        xs: 12,
                        sm: 12,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: 20.0,
                            left: isWide ? 8.0 : 0.0,
                          ),
                          child: SriTextField(
                            controller: state,
                            label: 'State',
                            labelColor: AppTheme.textPrimary,
                            borderColor: AppTheme.border,
                            iconColor: AppTheme.textMuted,
                            textColor: AppTheme.textPrimary,
                            fillColor: AppTheme.surfaceVariant,
                            readOnly: !editing,
                            prefixIcon: Icons.map_rounded,
                          ),
                        ),
                      ),
                      ResponsiveGridCol(
                        xl: 6,
                        lg: 6,
                        md: 6,
                        xs: 12,
                        sm: 12,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: 20.0,
                            right: isWide ? 8.0 : 0.0,
                          ),
                          child: SriTextField(
                            controller: city,
                            label: 'City',
                            labelColor: AppTheme.textPrimary,
                            borderColor: AppTheme.border,
                            iconColor: AppTheme.textMuted,
                            textColor: AppTheme.textPrimary,
                            fillColor: AppTheme.surfaceVariant,
                            readOnly: !editing,
                            prefixIcon: Icons.location_city_rounded,
                          ),
                        ),
                      ),
                      ResponsiveGridCol(
                        xl: 6,
                        lg: 6,
                        md: 6,
                        xs: 12,
                        sm: 12,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: 20.0,
                            left: isWide ? 8.0 : 0.0,
                          ),
                          child: SriTextField(
                            controller: pincode,
                            label: 'Pincode',
                            labelColor: AppTheme.textPrimary,
                            borderColor: AppTheme.border,
                            iconColor: AppTheme.textMuted,
                            textColor: AppTheme.textPrimary,
                            fillColor: AppTheme.surfaceVariant,
                            readOnly: !editing,
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.pin_drop_rounded,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // ── Geo-fencing ──────────────────────────────
              SriDetailCard(
                title: 'Geo-fencing (Attendance)',
                icon: Icons.radar_rounded,
                children: [
                  ResponsiveGridRow(
                    children: [
                      ResponsiveGridCol(
                        xl: 4,
                        lg: 4,
                        md: 4,
                        sm: 12,
                        xs: 12,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: 20.0,
                            right: isWide ? 8.0 : 0.0,
                          ),
                          child: SriTextField(
                            controller: lat,
                            label: 'Latitude',
                            readOnly: !editing,
                            labelColor: AppTheme.textPrimary,
                            borderColor: AppTheme.border,
                            iconColor: AppTheme.textMuted,
                            textColor: AppTheme.textPrimary,
                            fillColor: AppTheme.surfaceVariant,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            prefixIcon: Icons.my_location_rounded,
                          ),
                        ),
                      ),
                      ResponsiveGridCol(
                        xl: 4,
                        lg: 4,
                        md: 4,
                        sm: 12,
                        xs: 12,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: 20.0,
                            left: isWide ? 8.0 : 0.0,
                          ),
                          child: SriTextField(
                            controller: lon,
                            label: 'Longitude',
                            labelColor: AppTheme.textPrimary,
                            borderColor: AppTheme.border,
                            iconColor: AppTheme.textMuted,
                            textColor: AppTheme.textPrimary,
                            fillColor: AppTheme.surfaceVariant,
                            readOnly: !editing,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            prefixIcon: Icons.location_on_rounded,
                          ),
                        ),
                      ),
                      ResponsiveGridCol(
                        xl: 4,
                        lg: 4,
                        md: 4,
                        sm: 12,
                        xs: 12,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: 20.0,
                            left: isWide ? 8.0 : 0.0,
                          ),
                          child: SriTextField(
                            controller: radius,
                            label: 'Radius (m)',
                            labelColor: AppTheme.textPrimary,
                            borderColor: AppTheme.border,
                            iconColor: AppTheme.textMuted,
                            textColor: AppTheme.textPrimary,
                            fillColor: AppTheme.surfaceVariant,
                            readOnly: !editing,
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.circle_outlined,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget headerCard() {
    final c = widget.company;
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B5BDB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                clipBehavior: Clip.antiAlias,
                child: logoBytes != null
                    ? Image.memory(logoBytes!, fit: BoxFit.cover)
                    : (c["logo_url"]?.isNotEmpty == true
                          ? Image.network(
                              c["logo_url"]!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  widget.controller.logoPlaceholder(c),
                            )
                          : widget.controller.logoPlaceholder(c)),
              ),
              if (editing)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 11,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c["name"],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Nunito',
                  ),
                ),
                if (c["city"]?.isNotEmpty == true ||
                    c["state"]?.isNotEmpty == true)
                  Text(
                    '${c["city"] ?? ''}, ${c["state"] ?? ''}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 13,
                    ),
                  ),
                if (c["phone"]?.isNotEmpty == true)
                  Text(
                    c["phone"]!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.65),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
