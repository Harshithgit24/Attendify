import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';
import '../utils/app_theme.dart';
import '../utils/attendance_calculator.dart';

class OverallSummaryCard extends StatelessWidget {
  final VoidCallback onAdjustThreshold;

  const OverallSummaryCard({
    super.key,
    required this.onAdjustThreshold,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final overallPercentage = provider.overallPercentage;
    final status = provider.overallStatus;
    final statusColor = AppTheme.getStatusColor(status);
    final statusBg = AppTheme.getStatusBackgroundColor(status, isDark);
    final minReq = provider.minRequirement;

    final canMiss = provider.overallClassesCanMiss;
    final toAttend = provider.overallClassesToAttend;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Title & Threshold Chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.analytics_rounded,
                      color: AppTheme.primaryBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Overall Attendance',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onAdjustThreshold,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF475569)
                          : const Color(0xFFCBD5E1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Target: ${minReq.toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                              isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.tune_rounded,
                        size: 13,
                        color: AppTheme.primaryBlue,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Center Stats: Circular Indicator + Numbers
          Row(
            children: [
              // Radial Progress Circle
              SizedBox(
                width: 90,
                height: 90,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 90,
                      height: 90,
                      child: CircularProgressIndicator(
                        value: provider.overallTotalClasses == 0
                            ? 0.0
                            : (overallPercentage / 100.0).clamp(0.0, 1.0),
                        strokeWidth: 9,
                        strokeCap: StrokeCap.round,
                        backgroundColor: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          provider.overallTotalClasses == 0
                              ? '—'
                              : AttendanceCalculator.formatPercentage(
                                  overallPercentage),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          _getStatusLabel(status),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              // Breakdown: Total, Attended, Missed stats
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCol(
                      label: 'Total',
                      value: '${provider.overallTotalClasses}',
                      color: isDark ? Colors.white70 : const Color(0xFF475569),
                    ),
                    _buildStatCol(
                      label: 'Attended',
                      value: '${provider.overallAttendedClasses}',
                      color: AppTheme.safeGreen,
                    ),
                    _buildStatCol(
                      label: 'Missed',
                      value: '${provider.overallMissedClasses}',
                      color: AppTheme.criticalRed,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Smart Overall Prediction Banner
          if (provider.overallTotalClasses > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    status == AttendanceStatus.safe
                        ? Icons.check_circle_rounded
                        : status == AttendanceStatus.warning
                            ? Icons.warning_amber_rounded
                            : Icons.error_outline_rounded,
                    color: statusColor,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _buildAdviceText(status, canMiss, toAttend, minReq),
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCol({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  String _getStatusLabel(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.safe:
        return 'SAFE';
      case AttendanceStatus.warning:
        return 'WARNING';
      case AttendanceStatus.critical:
        return 'SHORTAGE';
      case AttendanceStatus.notStarted:
        return 'NO DATA';
    }
  }

  String _buildAdviceText(
    AttendanceStatus status,
    int canMiss,
    int toAttend,
    double minReq,
  ) {
    if (status == AttendanceStatus.safe) {
      if (canMiss > 0) {
        return 'You can safely miss $canMiss more class${canMiss > 1 ? 'es' : ''} overall without falling below ${minReq.toInt()}%.';
      }
      return 'You are exactly on track. Do not miss any upcoming classes.';
    } else {
      if (toAttend == -1) {
        return 'Requirement is 100%, which cannot be reached after missing classes.';
      }
      return 'Attend the next $toAttend consecutive class${toAttend > 1 ? 'es' : ''} to reach ${minReq.toInt()}%.';
    }
  }
}

