import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';
import '../utils/app_theme.dart';
import 'subject_dialog.dart';

class EmptyStateView extends StatelessWidget {
  final bool isFiltered;

  const EmptyStateView({
    super.key,
    required this.isFiltered,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.read<AttendanceProvider>();

    if (isFiltered) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  size: 40,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No Matching Subjects',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Try clearing your search query or changing the filter tab.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  provider.setFilter(SubjectFilter.all);
                  provider.setSearchQuery('');
                },
                icon: const Icon(Icons.clear_all_rounded, size: 18),
                label: const Text('Clear Filters'),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.school_rounded,
                size: 52,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Subjects Added Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your subjects to keep track of attendance percentages and predict how many classes you can safely miss.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => const SubjectDialog(),
                    );
                  },
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text('Add Subject'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => provider.resetToDemo(),
                  icon: const Icon(Icons.auto_stories_outlined, size: 18),
                  label: const Text('Load Demo'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

