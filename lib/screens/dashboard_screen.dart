import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/overall_summary_card.dart';
import '../widgets/subject_card.dart';
import '../widgets/subject_dialog.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = context.watch<AttendanceProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final subjects = attendanceProvider.filteredSubjects;
    final totalCount = attendanceProvider.allSubjects.length;
    final safeCount = attendanceProvider.safeSubjectsCount;
    final warningCount = attendanceProvider.warningSubjectsCount;
    final shortageCount = attendanceProvider.shortageSubjectsCount;

    return Scaffold(
      appBar: AppBar(
        title: _isSearchActive
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search subjects...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  hintStyle: TextStyle(
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                ),
                style: TextStyle(
                  fontSize: 17,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                onChanged: (val) => attendanceProvider.setSearchQuery(val),
              )
            : Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/icon/app_icon.jpg',
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Attendify',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
        actions: [
          // Search Toggle
          IconButton(
            icon: Icon(_isSearchActive
                ? Icons.close_rounded
                : Icons.search_rounded),
            tooltip: _isSearchActive ? 'Close search' : 'Search subjects',
            onPressed: () {
              setState(() {
                if (_isSearchActive) {
                  _searchController.clear();
                  attendanceProvider.setSearchQuery('');
                  _isSearchActive = false;
                } else {
                  _isSearchActive = true;
                }
              });
            },
          ),

          // Theme Toggle
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.dark ||
                      (themeProvider.themeMode == ThemeMode.system && isDark)
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            tooltip: 'Toggle Theme',
            onPressed: () => themeProvider.toggleTheme(),
          ),

          // Settings Button
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings & Formulas',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const SettingsScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // 1. Overall Summary Card (only if subjects exist or searching)
          if (totalCount > 0)
            SliverToBoxAdapter(
              child: OverallSummaryCard(
                onAdjustThreshold: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => const SettingsScreen(),
                    ),
                  );
                },
              ),
            ),

          // 2. Filter Tab Chips Row
          if (totalCount > 0)
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: 'All ($totalCount)',
                      filter: SubjectFilter.all,
                      activeColor: AppTheme.primaryBlue,
                      currentFilter: attendanceProvider.currentFilter,
                      onSelected: () =>
                          attendanceProvider.setFilter(SubjectFilter.all),
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Safe ($safeCount)',
                      filter: SubjectFilter.safe,
                      activeColor: AppTheme.safeGreen,
                      currentFilter: attendanceProvider.currentFilter,
                      onSelected: () =>
                          attendanceProvider.setFilter(SubjectFilter.safe),
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Warning ($warningCount)',
                      filter: SubjectFilter.warning,
                      activeColor: AppTheme.warningYellow,
                      currentFilter: attendanceProvider.currentFilter,
                      onSelected: () =>
                          attendanceProvider.setFilter(SubjectFilter.warning),
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Shortage ($shortageCount)',
                      filter: SubjectFilter.shortage,
                      activeColor: AppTheme.criticalRed,
                      currentFilter: attendanceProvider.currentFilter,
                      onSelected: () =>
                          attendanceProvider.setFilter(SubjectFilter.shortage),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),

          // 3. Subjects List or Empty State
          if (subjects.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyStateView(
                isFiltered: totalCount > 0,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(top: 4, bottom: 90),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final subject = subjects[index];
                    return SubjectCard(
                      key: ValueKey(subject.id),
                      subject: subject,
                    );
                  },
                  childCount: subjects.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (ctx) => const SubjectDialog(),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Subject',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required SubjectFilter filter,
    required Color activeColor,
    required SubjectFilter currentFilter,
    required VoidCallback onSelected,
    required bool isDark,
  }) {
    final isSelected = currentFilter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: activeColor.withValues(alpha: isDark ? 0.35 : 0.18),
      backgroundColor:
          isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
      side: BorderSide(
        color: isSelected
            ? activeColor
            : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        width: isSelected ? 1.5 : 1,
      ),
      labelStyle: TextStyle(
        color: isSelected
            ? (isDark ? Colors.white : activeColor)
            : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        fontSize: 12.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      showCheckmark: false,
    );
  }
}

