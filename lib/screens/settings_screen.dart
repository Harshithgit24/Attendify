import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = context.watch<AttendanceProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final currentTarget = attendanceProvider.minRequirement;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Formulas'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Section 1: Attendance Target
          _buildSectionHeader('ATTENDANCE TARGET', isDark),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Minimum Requirement',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${currentTarget.toInt()}%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Attendify uses this benchmark to calculate safe bunks and shortage recovery consecutive classes.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: currentTarget,
                    min: 50,
                    max: 100,
                    divisions: 50,
                    activeColor: AppTheme.primaryBlue,
                    label: '${currentTarget.toInt()}%',
                    onChanged: (val) {
                      attendanceProvider.updateMinRequirement(val);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('50%', style: _sliderSubStyle(isDark)),
                      Text('75% (Standard)',
                          style: _sliderSubStyle(isDark, isBold: true)),
                      Text('100%', style: _sliderSubStyle(isDark)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Section 2: Appearance
          _buildSectionHeader('APPEARANCE', isDark),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  _buildThemeTile(
                    context,
                    title: 'System Default',
                    subtitle: 'Follows operating system appearance',
                    mode: ThemeMode.system,
                    currentMode: themeProvider.themeMode,
                    icon: Icons.brightness_auto_rounded,
                    onTap: () => themeProvider.setThemeMode(ThemeMode.system),
                  ),
                  const Divider(height: 1),
                  _buildThemeTile(
                    context,
                    title: 'Light Theme',
                    subtitle: 'Clean, crisp high-contrast daylight mode',
                    mode: ThemeMode.light,
                    currentMode: themeProvider.themeMode,
                    icon: Icons.light_mode_rounded,
                    onTap: () => themeProvider.setThemeMode(ThemeMode.light),
                  ),
                  const Divider(height: 1),
                  _buildThemeTile(
                    context,
                    title: 'Dark Theme',
                    subtitle: 'OLED-friendly dark palette for night use',
                    mode: ThemeMode.dark,
                    currentMode: themeProvider.themeMode,
                    icon: Icons.dark_mode_rounded,
                    onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Section 3: Formula Reference Card
          _buildSectionHeader('MATHEMATICAL FORMULAS', isDark),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormulaItem(
                    title: '1. Basic Attendance',
                    formula: 'Attendance % = (Attended / Total) × 100',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildFormulaItem(
                    title: '2. Permissible Missed Classes (Safe Bunk)',
                    formula: 'm = ⌊(Attended / R) - Total⌋',
                    explanation:
                        'Where R is target (e.g. 0.75). Shows how many classes you can miss without dropping below R.',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildFormulaItem(
                    title: '3. Shortage Recovery Consecutive Classes',
                    formula: 'c = ⌈(R × Total - Attended) / (1 - R)⌉',
                    explanation:
                        'Shows consecutive classes you must attend without missing any to restore attendance to R.',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildFormulaItem(
                    title: '4. Future Projection After N Classes',
                    formula: 'P_attended = (Attended + N) / (Total + N) × 100\n'
                        'P_missed = Attended / (Total + N) × 100',
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Section 4: Data Management
          _buildSectionHeader('DATA MANAGEMENT', isDark),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.refresh_rounded,
                      color: AppTheme.primaryBlue),
                  title: const Text('Reset to Sample Subjects'),
                  subtitle: const Text(
                      'Restores standard demo subjects for testing'),
                  onTap: () {
                    attendanceProvider.resetToDemo();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Sample subjects restored.')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_forever_rounded,
                      color: AppTheme.criticalRed),
                  title: const Text(
                    'Clear All Data',
                    style: TextStyle(color: AppTheme.criticalRed),
                  ),
                  subtitle: const Text('Removes all subjects permanently'),
                  onTap: () => _confirmClearAll(context, attendanceProvider),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Footer
          Center(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/icon/app_icon.jpg',
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Attendify v1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Student Attendance & Future Prediction Tracker',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildThemeTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isSelected = mode == currentMode;
    return ListTile(
      leading: Icon(icon,
          color: isSelected ? AppTheme.primaryBlue : const Color(0xFF94A3B8)),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: AppTheme.primaryBlue)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildFormulaItem({
    required String title,
    required String formula,
    String? explanation,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            formula,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryBlue,
            ),
          ),
        ),
        if (explanation != null) ...[
          const SizedBox(height: 4),
          Text(
            explanation,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ],
      ],
    );
  }

  TextStyle _sliderSubStyle(bool isDark, {bool isBold = false}) {
    return TextStyle(
      fontSize: 11,
      fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
      color: isBold
          ? AppTheme.primaryBlue
          : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
    );
  }

  void _confirmClearAll(BuildContext context, AttendanceProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Subjects?'),
        content: const Text(
          'This will permanently delete all added subjects and attendance records.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.clearAllSubjects();
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.criticalRed,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}

