import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subject.dart';
import '../providers/attendance_provider.dart';
import '../utils/app_theme.dart';
import '../utils/attendance_calculator.dart';

class PredictionSheet extends StatefulWidget {
  final Subject subject;

  const PredictionSheet({
    super.key,
    required this.subject,
  });

  @override
  State<PredictionSheet> createState() => _PredictionSheetState();
}

class _PredictionSheetState extends State<PredictionSheet> {
  int _simulatedClasses = 5; // Default to 5 as requested in requirements!

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Use current updated subject from provider if exists
    final currentSubject = provider.allSubjects.firstWhere(
      (s) => s.id == widget.subject.id,
      orElse: () => widget.subject,
    );

    final globalReq = provider.minRequirement;
    final effectiveReq = currentSubject.effectiveRequirement(globalReq);
    final status = currentSubject.status(globalReq);
    final statusColor = AppTheme.getStatusColor(status);
    final statusBg = AppTheme.getStatusBackgroundColor(status, isDark);

    final canMiss = currentSubject.classesCanMiss(globalReq);
    final toAttend = currentSubject.classesToAttend(globalReq);

    // Simulated calculations
    final projectedAfterAttending =
        AttendanceCalculator.predictAttendanceAfterAttending(
      attended: currentSubject.attendedClasses,
      total: currentSubject.totalClasses,
      nextClasses: _simulatedClasses,
    );

    final projectedAfterMissing =
        AttendanceCalculator.predictAttendanceAfterMissing(
      attended: currentSubject.attendedClasses,
      total: currentSubject.totalClasses,
      nextClasses: _simulatedClasses,
    );

    final currentPct = currentSubject.percentage;
    final diffAttending = projectedAfterAttending - currentPct;
    final diffMissing = projectedAfterMissing - currentPct;

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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Sheet Title & Subject info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_graph_rounded,
                            size: 20,
                            color: AppTheme.primaryBlue,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Attendance Predictor',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentSubject.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    currentSubject.totalClasses == 0
                        ? '0%'
                        : AttendanceCalculator.formatPercentage(currentPct),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Current Stats Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Total', '${currentSubject.totalClasses}'),
                  _buildStatDivider(isDark),
                  _buildStatItem('Attended', '${currentSubject.attendedClasses}',
                      color: AppTheme.safeGreen),
                  _buildStatDivider(isDark),
                  _buildStatItem('Missed', '${currentSubject.missedClasses}',
                      color: AppTheme.criticalRed),
                  _buildStatDivider(isDark),
                  _buildStatItem('Target', '${effectiveReq.toInt()}%'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section 1: Core Prediction Answers
            const Text(
              'Prediction Insights',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),

            // Insight A: Safe Bunking
            _buildInsightCard(
              isDark: isDark,
              icon: Icons.beach_access_rounded,
              iconColor: AppTheme.safeGreen,
              title: 'Classes You Can Safely Miss',
              value: '$canMiss classes',
              description: canMiss > 0
                  ? 'You can miss the next $canMiss classes without falling below ${effectiveReq.toInt()}%. Attendance after $canMiss missed classes will be ${AttendanceCalculator.formatPercentage(AttendanceCalculator.predictAttendanceAfterMissing(attended: currentSubject.attendedClasses, total: currentSubject.totalClasses, nextClasses: canMiss))}.'
                  : 'You cannot miss any more classes. You are on the verge or below ${effectiveReq.toInt()}%.',
            ),
            const SizedBox(height: 10),

            // Insight B: Shortage Recovery
            _buildInsightCard(
              isDark: isDark,
              icon: Icons.event_available_rounded,
              iconColor: toAttend > 0 ? AppTheme.warningYellow : AppTheme.safeGreen,
              title: 'Consecutive Classes Required to Reach Target',
              value: toAttend == -1
                  ? 'Impossible'
                  : toAttend == 0
                      ? 'Target Achieved'
                      : '$toAttend consecutive classes',
              description: toAttend > 0
                  ? 'You are currently below ${effectiveReq.toInt()}%. You must attend the next $toAttend classes continuously without missing any to restore your attendance.'
                  : toAttend == -1
                      ? 'Target is 100%, but classes have already been missed.'
                      : 'You already meet or exceed the required ${effectiveReq.toInt()}% attendance.',
            ),

            const SizedBox(height: 24),

            // Section 2: Interactive "What-If" Simulator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'What-If Simulator',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Next $_simulatedClasses Classes',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Presets row (+1, +3, +5, +10, +15)
            Row(
              children: [1, 3, 5, 10, 15].map((count) {
                final isSelected = _simulatedClasses == count;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('+$count classes'),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _simulatedClasses = count);
                      }
                    },
                    selectedColor: AppTheme.primaryBlue,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : const Color(0xFF334155)),
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }).toList(),
            ),

            // Slider
            Slider(
              value: _simulatedClasses.toDouble(),
              min: 1,
              max: 30,
              divisions: 29,
              activeColor: AppTheme.primaryBlue,
              label: '$_simulatedClasses classes',
              onChanged: (val) {
                setState(() => _simulatedClasses = val.toInt());
              },
            ),

            const SizedBox(height: 8),

            // Side-by-side Simulation Results
            Row(
              children: [
                // If Attend Next N
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.safeGreenDark.withValues(alpha: 0.3)
                          : AppTheme.safeGreenLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.safeGreen.withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: AppTheme.safeGreen,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'If Attended',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white
                                    : AppTheme.safeGreenDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AttendanceCalculator.formatPercentage(
                              projectedAfterAttending),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.safeGreen,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${diffAttending >= 0 ? '+' : ''}${diffAttending.toStringAsFixed(1)}% change',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? const Color(0xFF6EE7B7)
                                : AppTheme.safeGreenDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${currentSubject.attendedClasses + _simulatedClasses} / ${currentSubject.totalClasses + _simulatedClasses}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white54 : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // If Missed Next N
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.criticalRedDark.withValues(alpha: 0.3)
                          : AppTheme.criticalRedLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.criticalRed.withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.cancel_rounded,
                              size: 16,
                              color: AppTheme.criticalRed,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'If Missed',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white
                                    : AppTheme.criticalRedDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AttendanceCalculator.formatPercentage(
                              projectedAfterMissing),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.criticalRed,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${diffMissing >= 0 ? '+' : ''}${diffMissing.toStringAsFixed(1)}% change',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? const Color(0xFFFCA5A5)
                                : AppTheme.criticalRedDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${currentSubject.attendedClasses} / ${currentSubject.totalClasses + _simulatedClasses}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white54 : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Close Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider(bool isDark) {
    return Container(
      width: 1,
      height: 24,
      color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
    );
  }

  Widget _buildInsightCard({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: iconColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: isDark ? Colors.white70 : const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}

