// lib/widgets/form_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FormField2 {
  final String key;
  final String label;
  final FormFieldType type;
  final bool required;
  final List<String>? options;
  final String? hint;
  final bool readOnly;

  const FormField2({
    required this.key,
    required this.label,
    this.type = FormFieldType.text,
    this.required = false,
    this.options,
    this.hint,
    this.readOnly = false,
  });
}

enum FormFieldType {
  text,
  email,
  phone,
  number,
  date,
  time,
  bool,
  dropdown,
  textarea,
  uuid,
}

class FormDialog extends StatefulWidget {
  final String title;
  final List<FormField2> fields;
  final Map<String, dynamic>? initialData;
  final Future<void> Function(Map<String, dynamic> data) onSave;

  const FormDialog({
    super.key,
    required this.title,
    required this.fields,
    this.initialData,
    required this.onSave,
  });

  @override
  State<FormDialog> createState() => _FormDialogState();
}

class _FormDialogState extends State<FormDialog> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _data;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _data = {};
    if (widget.initialData != null) {
      _data = Map<String, dynamic>.from(widget.initialData!);
    }
    // Initialize booleans
    for (final f in widget.fields) {
      if (f.type == FormFieldType.bool) {
        _data[f.key] ??= false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isWide ? 600 : double.infinity,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: widget.fields.map((f) {
                      final double w =
                          isWide &&
                              f.type != FormFieldType.textarea &&
                              f.type != FormFieldType.bool
                          ? (600 - 56) / 2
                          : double.infinity;
                      return SizedBox(width: w, child: _buildField(f));
                    }).toList(),
                  ),
                ),
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _saving ? null : () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Save'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(FormField2 f) {
    switch (f.type) {
      case FormFieldType.bool:
        return Row(
          children: [
            Obx(() {
              // Use local bool state
              return Checkbox(
                value: _data[f.key] as bool? ?? false,
                onChanged: (v) => setState(() => _data[f.key] = v ?? false),
              );
            }),
            Text(f.label),
          ],
        );

      case FormFieldType.dropdown:
        return DropdownButtonFormField<String>(
          value: _data[f.key]?.toString(),
          decoration: InputDecoration(labelText: f.label, hintText: f.hint),
          items: (f.options ?? [])
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: (v) => setState(() => _data[f.key] = v),
          validator: f.required
              ? (v) => v == null ? '${f.label} is required' : null
              : null,
        );

      case FormFieldType.textarea:
        return TextFormField(
          initialValue: _data[f.key]?.toString(),
          maxLines: 3,
          readOnly: f.readOnly,
          decoration: InputDecoration(labelText: f.label, hintText: f.hint),
          onChanged: (v) => _data[f.key] = v,
          validator: f.required
              ? (v) =>
                    (v == null || v.isEmpty) ? '${f.label} is required' : null
              : null,
        );

      case FormFieldType.date:
        return TextFormField(
          initialValue: _data[f.key]?.toString().split('T').first,
          readOnly: true,
          decoration: InputDecoration(
            labelText: f.label,
            hintText: 'YYYY-MM-DD',
            suffixIcon: const Icon(Icons.calendar_today, size: 18),
          ),
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate:
                  DateTime.tryParse(_data[f.key]?.toString() ?? '') ??
                  DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (d != null) {
              setState(
                () => _data[f.key] =
                    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
              );
            }
          },
          validator: f.required
              ? (v) =>
                    (v == null || v.isEmpty) ? '${f.label} is required' : null
              : null,
        );

      case FormFieldType.time:
        return TextFormField(
          initialValue: _data[f.key]?.toString(),
          readOnly: true,
          decoration: InputDecoration(
            labelText: f.label,
            hintText: 'HH:MM',
            suffixIcon: const Icon(Icons.access_time, size: 18),
          ),
          onTap: () async {
            final t = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (t != null) {
              setState(
                () => _data[f.key] =
                    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
              );
            }
          },
        );

      case FormFieldType.number:
        return TextFormField(
          initialValue: _data[f.key]?.toString(),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: f.label, hintText: f.hint),
          onChanged: (v) => _data[f.key] = num.tryParse(v) ?? v,
          validator: f.required
              ? (v) =>
                    (v == null || v.isEmpty) ? '${f.label} is required' : null
              : null,
        );

      case FormFieldType.uuid:
        return TextFormField(
          initialValue: _data[f.key]?.toString(),
          readOnly: f.readOnly,
          decoration: InputDecoration(
            labelText: f.label,
            hintText: f.hint ?? 'UUID',
          ),
          onChanged: (v) => _data[f.key] = v,
        );

      default:
        return TextFormField(
          initialValue: _data[f.key]?.toString(),
          readOnly: f.readOnly,
          keyboardType: f.type == FormFieldType.email
              ? TextInputType.emailAddress
              : f.type == FormFieldType.phone
              ? TextInputType.phone
              : TextInputType.text,
          decoration: InputDecoration(labelText: f.label, hintText: f.hint),
          onChanged: (v) => _data[f.key] = v,
          validator: f.required
              ? (v) =>
                    (v == null || v.isEmpty) ? '${f.label} is required' : null
              : null,
        );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      // Clean empty strings to null
      final cleaned = _data.map((k, v) {
        if (v is String && v.isEmpty) return MapEntry(k, null);
        return MapEntry(k, v);
      });
      await widget.onSave(cleaned);
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
