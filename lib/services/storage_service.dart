import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subject.dart';

/// Service responsible for persisting subjects, thresholds, and preferences locally.
class StorageService {
  static const String _keySubjects = 'attendify_subjects_v1';
  static const String _keyMinRequirement = 'attendify_min_requirement_v1';
  static const String _keyThemeMode = 'attendify_theme_mode_v1';
  static const String _keyInitialized = 'attendify_has_initialized_v1';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  /// Loads subjects list from local storage.
  /// If it's the user's first launch, populates realistic sample data.
  List<Subject> loadSubjects() {
    final rawJson = _prefs.getString(_keySubjects);
    if (rawJson == null || rawJson.trim().isEmpty) {
      if (!_prefs.containsKey(_keyInitialized)) {
        // Prepopulate sample data on first launch
        final demoSubjects = _getDemoSubjects();
        saveSubjects(demoSubjects);
        _prefs.setBool(_keyInitialized, true);
        return demoSubjects;
      }
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;
      return decoded
          .map((item) => Subject.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error parsing saved subjects: $e');
      return [];
    }
  }

  /// Saves list of subjects as JSON to local storage.
  Future<bool> saveSubjects(List<Subject> subjects) async {
    final encoded = jsonEncode(subjects.map((s) => s.toJson()).toList());
    return await _prefs.setString(_keySubjects, encoded);
  }

  /// Loads the minimum required attendance percentage (defaults to 75.0).
  double loadMinRequirement() {
    return _prefs.getDouble(_keyMinRequirement) ?? 75.0;
  }

  /// Saves the minimum required attendance percentage.
  Future<bool> saveMinRequirement(double percentage) async {
    return await _prefs.setDouble(_keyMinRequirement, percentage);
  }

  /// Loads saved ThemeMode: 'light', 'dark', or 'system' (default).
  ThemeMode loadThemeMode() {
    final val = _prefs.getString(_keyThemeMode);
    switch (val) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Saves selected ThemeMode.
  Future<bool> saveThemeMode(ThemeMode mode) async {
    String value;
    switch (mode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      case ThemeMode.system:
        value = 'system';
        break;
    }
    return await _prefs.setString(_keyThemeMode, value);
  }

  /// Resets all data to demo state.
  Future<List<Subject>> resetToDemo() async {
    final demo = _getDemoSubjects();
    await saveSubjects(demo);
    await saveMinRequirement(75.0);
    return demo;
  }

  /// Clears all subjects.
  Future<void> clearAllSubjects() async {
    await _prefs.remove(_keySubjects);
  }

  /// Realistic demo data showcasing safe, warning, and shortage scenarios.
  List<Subject> _getDemoSubjects() {
    return [
      Subject(
        id: 'demo_1',
        name: 'Data Structures & Algorithms',
        totalClasses: 40,
        attendedClasses: 32, // 80% (Safe: can miss 2)
        colorValue: const Color(0xFF6366F1).toARGB32(),
      ),
      Subject(
        id: 'demo_2',
        name: 'Database Management Systems',
        totalClasses: 36,
        attendedClasses: 30, // 83.3% (Safe: can miss 4)
        colorValue: const Color(0xFF0EA5E9).toARGB32(),
      ),
      Subject(
        id: 'demo_3',
        name: 'Computer Networks',
        totalClasses: 35,
        attendedClasses: 25, // 71.4% (Warning: within 5% of 75%)
        colorValue: const Color(0xFFF59E0B).toARGB32(),
      ),
      Subject(
        id: 'demo_4',
        name: 'Operating Systems',
        totalClasses: 30,
        attendedClasses: 18, // 60.0% (Critical shortage: needs 18 consecutive)
        colorValue: const Color(0xFFEF4444).toARGB32(),
      ),
    ];
  }
}

