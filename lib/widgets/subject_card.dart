import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/subject.dart';
import '../providers/attendance_provider.dart';
import '../utils/app_theme.dart';
import '../utils/attendance_calculator.dart';
import 'prediction_sheet.dart';
import 'subject_dialog.dart';

class SubjectCard extends StatelessWidget {
  final Subject subject;

  const SubjectCard({
    super.key,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final globalReq = provider.minRequirement;
    final effectiveReq = subject.effectiveRequirement(globalReq);
    final percentage = subject.percentage;
    final status = subject.status(globalReq);
    final statusColor = AppTheme.getStatusColor(status);
    final statusBg = AppTheme.getStatusBackgroundColor(status, isDark);

    final canMiss = subject.classesCanMiss(globalReq);
    final toAttend = subject.classesToAttend(globalReq);

    final cardBorder = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Subject Avatar + Name + Percentage Badge + Menu
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Subject Initial Badge
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Color(subject.colorValue).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Color(subject.colorValue).withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    subject.name.isNotEmpty
                        ? subject.name.substring(0, 1).toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: Color(subject.colorValue),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Subject Name & Target info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            'Target: ${effectiveReq.toInt()}%',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (subject.customRequirement != null) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Custom',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Percentage Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        subject.totalClasses == 0
                            ? '—'
                            : AttendanceCalculator.formatPercentage(percentage),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Popup Options Menu
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    size: 20,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onSelected: (value) {
                    if (value == 'simulate') {
                      _openPredictionModal(context, subject);
                    } else if (value == 'edit') {
                      _openEditDialog(context, subject);
                    } else if (value == 'delete') {
                      _confirmDelete(context, provider, subject);
                    } else if (value == 'undo_attended') {
                      provider.undoAttended(subject.id);
                    } else if (value == 'undo_missed') {
                      provider.undoMissed(subject.id);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'simulate',
                      child: Row(
                        children: [
                          Icon(Icons.auto_graph_rounded,
                              size: 18, color: AppTheme.primaryBlue),
                          SizedBox(width: 10),
                          Text('Simulate Future'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 10),
                          Text('Edit Subject'),
                        ],
                      ),
                    ),
                    if (subject.attendedClasses > 0)
                      const PopupMenuItem(
                        value: 'undo_attended',
                        child: Row(
                          children: [
                            Icon(Icons.undo_rounded, size: 18),
                            SizedBox(width: 10),
                            Text('Undo Last Attended'),
                          ],
                        ),
                      ),
                    if (subject.missedClasses > 0)
                      const PopupMenuItem(
                        value: 'undo_missed',
                        child: Row(
                          children: [
                            Icon(Icons.undo_rounded, size: 18),
                            SizedBox(width: 10),
                            Text('Undo Last Missed'),
                          ],
                        ),
                      ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded,
                              size: 18, color: AppTheme.criticalRed),
                          SizedBox(width: 10),
                          Text('Delete',
                              style: TextStyle(color: AppTheme.criticalRed)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Visual Progress Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: subject.totalClasses == 0
                    ? 0.0
                    : (percentage / 100.0).clamp(0.0, 1.0),
                minHeight: 7,
                backgroundColor: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
          ),

          // Attended vs Missed stats summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Attended: ${subject.attendedClasses} / ${subject.totalClasses} classes',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : const Color(0xFF475569),
                  ),
                ),
                Text(
                  'Missed: ${subject.missedClasses}',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: subject.missedClasses > 0
                        ? AppTheme.criticalRed
                        : (isDark ? Colors.white54 : const Color(0xFF94A3B8)),
                  ),
                ),
              ],
            ),
          ),

          // Smart Predictive Advice Callout
          if (subject.totalClasses > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      status == AttendanceStatus.safe
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 15,
                      color: statusColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _buildPredictionAdvice(
                            status, canMiss, toAttend, effectiveReq),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color:
                              isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Action Buttons: + Attended | + Missed | Simulator
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
            child: Row(
              children: [
                // Quick + Attended Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      provider.recordAttended(subject.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.safeGreen.withValues(
                          alpha: isDark ? 0.25 : 0.12),
                      foregroundColor: isDark
                          ? const Color(0xFF6EE7B7)
                          : AppTheme.safeGreenDark,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: AppTheme.safeGreen.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.add_circle_outline_rounded,
                        size: 16),
                    label: const Text(
                      'Attended',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Quick + Missed Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      provider.recordMissed(subject.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.criticalRed.withValues(
                          alpha: isDark ? 0.25 : 0.1),
                      foregroundColor: isDark
                          ? const Color(0xFFFCA5A5)
                          : AppTheme.criticalRedDark,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: AppTheme.criticalRed.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.remove_circle_outline_rounded,
                        size: 16),
                    label: const Text(
                      'Missed',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Predict Button
                IconButton.filledTonal(
                  onPressed: () => _openPredictionModal(context, subject),
                  tooltip: 'Predict Future Attendance',
                  style: IconButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFF1F5F9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(
                    Icons.auto_graph_rounded,
                    size: 18,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildPredictionAdvice(
    AttendanceStatus status,
    int canMiss,
    int toAttend,
    double req,
  ) {
    if (status == AttendanceStatus.safe) {
      if (canMiss > 0) {
        return 'Can miss $canMiss more class${canMiss > 1 ? 'es' : ''} safely.';
      }
      return 'Boundary reached: attend all next classes to stay >= ${req.toInt()}%.';
    } else {
      if (toAttend == -1) {
        return 'Cannot recover to 100% after missing classes.';
      }
      return 'Must attend next $toAttend consecutive class${toAttend > 1 ? 'es' : ''} to reach ${req.toInt()}%.';
    }
  }

  void _openPredictionModal(BuildContext context, Subject subject) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PredictionSheet(subject: subject),
    );
  }

  void _openEditDialog(BuildContext context, Subject subject) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SubjectDialog(subjectToEdit: subject),
    );
  }

  void _confirmDelete(
    BuildContext context,
    AttendanceProvider provider,
    Subject subject,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Subject?'),
        content: Text(
          'Are you sure you want to delete "${subject.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteSubject(subject.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${subject.name}" deleted'),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      provider.addSubject(
                        name: subject.name,
                        totalClasses: subject.totalClasses,
                        attendedClasses: subject.attendedClasses,
                        customRequirement: subject.customRequirement,
                        colorValue: subject.colorValue,
                      );
                    },
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.criticalRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

