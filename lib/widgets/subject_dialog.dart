import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/subject.dart';
import '../providers/attendance_provider.dart';
import '../utils/app_theme.dart';
import '../utils/attendance_calculator.dart';

class SubjectDialog extends StatefulWidget {
  final Subject? subjectToEdit;

  const SubjectDialog({
    super.key,
    this.subjectToEdit,
  });

  @override
  State<SubjectDialog> createState() => _SubjectDialogState();
}

class _SubjectDialogState extends State<SubjectDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _totalController;
  late TextEditingController _attendedController;

  bool _useCustomReq = false;
  double _customReqValue = 75.0;
  int _selectedColor = const Color(0xFF6366F1).toARGB32();

  final List<Color> _colors = const [
    Color(0xFF6366F1), // Indigo
    Color(0xFF0EA5E9), // Sky
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFF14B8A6), // Teal
    Color(0xFFF97316), // Orange
  ];

  @override
  void initState() {
    super.initState();
    final edit = widget.subjectToEdit;
    if (edit != null) {
      _nameController = TextEditingController(text: edit.name);
      _totalController =
          TextEditingController(text: edit.totalClasses.toString());
      _attendedController =
          TextEditingController(text: edit.attendedClasses.toString());
      _useCustomReq = edit.customRequirement != null;
      _customReqValue = edit.customRequirement ?? 75.0;
      _selectedColor = edit.colorValue;
    } else {
      _nameController = TextEditingController();
      _totalController = TextEditingController(text: '0');
      _attendedController = TextEditingController(text: '0');
    }

    _totalController.addListener(() => setState(() {}));
    _attendedController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _totalController.dispose();
    _attendedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.subjectToEdit != null;
    final globalReq = context.read<AttendanceProvider>().minRequirement;

    final total = int.tryParse(_totalController.text) ?? 0;
    final attended = int.tryParse(_attendedController.text) ?? 0;
    final missed = AttendanceCalculator.calculateMissed(attended, total);
    final previewPct =
        AttendanceCalculator.calculatePercentage(attended, total);
    final reqToCompare = _useCustomReq ? _customReqValue : globalReq;
    final status = AttendanceCalculator.getStatus(
      attended: attended,
      total: total,
      requiredPercentage: reqToCompare,
    );
    final statusColor = AppTheme.getStatusColor(status);

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle Bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF475569)
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Subject' : 'Add New Subject',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Subject Name
              Text(
                'Subject Name',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'e.g. Machine Learning, Physics',
                  prefixIcon: Icon(Icons.school_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a subject name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Attendance Numbers: Total & Attended
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total Classes
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Classes',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _totalController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: const InputDecoration(
                            hintText: '0',
                            prefixIcon: Icon(Icons.calendar_month_outlined),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Enter total';
                            }
                            final parsed = int.tryParse(val);
                            if (parsed == null || parsed < 0) {
                              return 'Must be >= 0';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Attended Classes
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Classes Attended',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _attendedController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: const InputDecoration(
                            hintText: '0',
                            prefixIcon: Icon(Icons.check_circle_outline_rounded),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Enter attended';
                            }
                            final parsedAttended = int.tryParse(val);
                            final parsedTotal =
                                int.tryParse(_totalController.text) ?? 0;
                            if (parsedAttended == null || parsedAttended < 0) {
                              return 'Must be >= 0';
                            }
                            if (parsedAttended > parsedTotal) {
                              return 'Cannot exceed total';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Live Preview Banner: Missed & Percentage
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.visibility_outlined,
                          size: 18,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Missed Classes: $missed',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          total == 0
                              ? '100%'
                              : AttendanceCalculator.formatPercentage(
                                  previewPct),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Color Theme Picker
              Text(
                'Card Accent Color',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _colors.map((color) {
                  final isSelected = _selectedColor == color.toARGB32();
                  return InkWell(
                    onTap: () =>
                        setState(() => _selectedColor = color.toARGB32()),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(
                                color: isDark ? Colors.white : Colors.black,
                                width: 2.5,
                              )
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 18),

              // Custom Requirement Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Custom Minimum Requirement',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _useCustomReq
                            ? 'Overriding default (${_customReqValue.toInt()}%)'
                            : 'Using global target (${globalReq.toInt()}%)',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: _useCustomReq,
                    activeThumbColor: AppTheme.primaryBlue,
                    onChanged: (val) {
                      setState(() {
                        _useCustomReq = val;
                        if (val && _customReqValue == 75.0) {
                          _customReqValue = globalReq;
                        }
                      });
                    },
                  ),
                ],
              ),

              if (_useCustomReq) ...[
                Slider(
                  value: _customReqValue,
                  min: 50,
                  max: 100,
                  divisions: 50,
                  activeColor: AppTheme.primaryBlue,
                  label: '${_customReqValue.toInt()}%',
                  onChanged: (val) => setState(() => _customReqValue = val),
                ),
              ],

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveSubject,
                  child: Text(isEditing ? 'Save Changes' : 'Add Subject'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveSubject() {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AttendanceProvider>();
    final name = _nameController.text.trim();
    final total = int.parse(_totalController.text.trim());
    final attended = int.parse(_attendedController.text.trim());
    final customReq = _useCustomReq ? _customReqValue : null;

    if (widget.subjectToEdit != null) {
      final updated = widget.subjectToEdit!.copyWith(
        name: name,
        totalClasses: total,
        attendedClasses: attended,
        customRequirement: customReq,
        clearCustomRequirement: !_useCustomReq,
        colorValue: _selectedColor,
      );
      provider.updateSubject(updated);
    } else {
      provider.addSubject(
        name: name,
        totalClasses: total,
        attendedClasses: attended,
        customRequirement: customReq,
        colorValue: _selectedColor,
      );
    }

    Navigator.of(context).pop();
  }
}
