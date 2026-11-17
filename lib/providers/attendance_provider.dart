import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../services/storage_service.dart';
import '../utils/attendance_calculator.dart';

enum SubjectFilter {
  all,
  safe,
  warning,
  shortage,
}

class AttendanceProvider extends ChangeNotifier {
  final StorageService _storageService;

  List<Subject> _subjects = [];
  double _minRequirement = 75.0;
  SubjectFilter _currentFilter = SubjectFilter.all;
  String _searchQuery = '';

  AttendanceProvider(this._storageService) {
    _loadData();
  }

  void _loadData() {
    _minRequirement = _storageService.loadMinRequirement();
    _subjects = _storageService.loadSubjects();
    notifyListeners();
  }

  // Getters
  List<Subject> get allSubjects => List.unmodifiable(_subjects);
  double get minRequirement => _minRequirement;
  SubjectFilter get currentFilter => _currentFilter;
  String get searchQuery => _searchQuery;

  /// Returns filtered and searched subjects list.
  List<Subject> get filteredSubjects {
    return _subjects.where((subject) {
      // 1. Text Search Filter
      if (_searchQuery.isNotEmpty) {
        final matches = subject.name.toLowerCase().contains(_searchQuery.toLowerCase());
        if (!matches) return false;
      }

      // 2. Status Category Filter
      final status = subject.status(_minRequirement);
      switch (_currentFilter) {
        case SubjectFilter.all:
          return true;
        case SubjectFilter.safe:
          return status == AttendanceStatus.safe;
        case SubjectFilter.warning:
          return status == AttendanceStatus.warning;
        case SubjectFilter.shortage:
          return status == AttendanceStatus.critical;
      }
    }).toList();
  }

  // Overall Statistics
  int get overallTotalClasses =>
      _subjects.fold(0, (sum, s) => sum + s.totalClasses);

  int get overallAttendedClasses =>
      _subjects.fold(0, (sum, s) => sum + s.attendedClasses);

  int get overallMissedClasses =>
      _subjects.fold(0, (sum, s) => sum + s.missedClasses);

  double get overallPercentage => AttendanceCalculator.calculatePercentage(
        overallAttendedClasses,
        overallTotalClasses,
      );

  AttendanceStatus get overallStatus => AttendanceCalculator.getStatus(
        attended: overallAttendedClasses,
        total: overallTotalClasses,
        requiredPercentage: _minRequirement,
      );

  int get overallClassesCanMiss => AttendanceCalculator.calculateClassesCanMiss(
        attended: overallAttendedClasses,
        total: overallTotalClasses,
        requiredPercentage: _minRequirement,
      );

  int get overallClassesToAttend => AttendanceCalculator.calculateClassesToAttend(
        attended: overallAttendedClasses,
        total: overallTotalClasses,
        requiredPercentage: _minRequirement,
      );

  // Subject Counts per Status
  int get safeSubjectsCount => _subjects
      .where((s) => s.status(_minRequirement) == AttendanceStatus.safe)
      .length;

  int get warningSubjectsCount => _subjects
      .where((s) => s.status(_minRequirement) == AttendanceStatus.warning)
      .length;

  int get shortageSubjectsCount => _subjects
      .where((s) => s.status(_minRequirement) == AttendanceStatus.critical)
      .length;

  // Filter & Search Setters
  void setFilter(SubjectFilter filter) {
    if (_currentFilter == filter) return;
    _currentFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // CRUD Operations
  Future<void> addSubject({
    required String name,
    required int totalClasses,
    required int attendedClasses,
    double? customRequirement,
    int? colorValue,
  }) async {
    final newSubject = Subject(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      totalClasses: totalClasses,
      attendedClasses: attendedClasses,
      customRequirement: customRequirement,
      colorValue: colorValue,
    );

    _subjects.insert(0, newSubject);
    await _persist();
    notifyListeners();
  }

  Future<void> updateSubject(Subject updated) async {
    final index = _subjects.indexWhere((s) => s.id == updated.id);
    if (index != -1) {
      _subjects[index] = updated;
      await _persist();
      notifyListeners();
    }
  }

  Future<void> deleteSubject(String id) async {
    _subjects.removeWhere((s) => s.id == id);
    await _persist();
    notifyListeners();
  }

  // Quick Action Helpers
  Future<void> recordAttended(String id) async {
    final index = _subjects.indexWhere((s) => s.id == id);
    if (index != -1) {
      _subjects[index] = _subjects[index].recordAttended();
      await _persist();
      notifyListeners();
    }
  }

  Future<void> recordMissed(String id) async {
    final index = _subjects.indexWhere((s) => s.id == id);
    if (index != -1) {
      _subjects[index] = _subjects[index].recordMissed();
      await _persist();
      notifyListeners();
    }
  }

  Future<void> undoAttended(String id) async {
    final index = _subjects.indexWhere((s) => s.id == id);
    if (index != -1) {
      _subjects[index] = _subjects[index].undoAttended();
      await _persist();
      notifyListeners();
    }
  }

  Future<void> undoMissed(String id) async {
    final index = _subjects.indexWhere((s) => s.id == id);
    if (index != -1) {
      _subjects[index] = _subjects[index].undoMissed();
      await _persist();
      notifyListeners();
    }
  }

  // Settings
  Future<void> updateMinRequirement(double newThreshold) async {
    if (newThreshold < 10.0) newThreshold = 10.0;
    if (newThreshold > 100.0) newThreshold = 100.0;
    _minRequirement = newThreshold;
    await _storageService.saveMinRequirement(newThreshold);
    notifyListeners();
  }

  Future<void> resetToDemo() async {
    _subjects = await _storageService.resetToDemo();
    _minRequirement = 75.0;
    _currentFilter = SubjectFilter.all;
    _searchQuery = '';
    notifyListeners();
  }

  Future<void> clearAllSubjects() async {
    _subjects.clear();
    await _storageService.clearAllSubjects();
    notifyListeners();
  }

  Future<void> _persist() async {
    await _storageService.saveSubjects(_subjects);
  }
}

