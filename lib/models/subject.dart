import 'package:flutter/material.dart';
import '../utils/attendance_calculator.dart';

/// Represents a single academic subject in Attendify.
class Subject {
  final String id;
  final String name;
  final int totalClasses;
  final int attendedClasses;
  final double? customRequirement; // null means inherit global requirement
  final int colorValue;
  final DateTime lastUpdated;

  Subject({
    required this.id,
    required this.name,
    required this.totalClasses,
    required this.attendedClasses,
    this.customRequirement,
    int? colorValue,
    DateTime? lastUpdated,
  })  : colorValue = colorValue ?? _defaultColorFor(name),
        lastUpdated = lastUpdated ?? DateTime.now();

  /// Missed classes count: total - attended (minimum 0).
  int get missedClasses =>
      AttendanceCalculator.calculateMissed(attendedClasses, totalClasses);

  /// Current attendance percentage (0.0 - 100.0).
  double get percentage =>
      AttendanceCalculator.calculatePercentage(attendedClasses, totalClasses);

  /// Returns effective required percentage (custom if set, else global).
  double effectiveRequirement(double globalRequirement) {
    return customRequirement ?? globalRequirement;
  }

  /// Calculates status given the active requirement.
  AttendanceStatus status(double globalRequirement) {
    return AttendanceCalculator.getStatus(
      attended: attendedClasses,
      total: totalClasses,
      requiredPercentage: effectiveRequirement(globalRequirement),
    );
  }

  /// Calculates safe bunkable classes given the active requirement.
  int classesCanMiss(double globalRequirement) {
    return AttendanceCalculator.calculateClassesCanMiss(
      attended: attendedClasses,
      total: totalClasses,
      requiredPercentage: effectiveRequirement(globalRequirement),
    );
  }

  /// Calculates consecutive classes needed to recover given the active requirement.
  int classesToAttend(double globalRequirement) {
    return AttendanceCalculator.calculateClassesToAttend(
      attended: attendedClasses,
      total: totalClasses,
      requiredPercentage: effectiveRequirement(globalRequirement),
    );
  }

  /// Quick action: Attended today (+1 attended, +1 total).
  Subject recordAttended() {
    return copyWith(
      attendedClasses: attendedClasses + 1,
      totalClasses: totalClasses + 1,
      lastUpdated: DateTime.now(),
    );
  }

  /// Quick action: Missed today (+1 total, attended unchanged).
  Subject recordMissed() {
    return copyWith(
      totalClasses: totalClasses + 1,
      lastUpdated: DateTime.now(),
    );
  }

  /// Quick action: Undo attended (-1 attended, -1 total if > 0).
  Subject undoAttended() {
    if (attendedClasses <= 0 || totalClasses <= 0) return this;
    return copyWith(
      attendedClasses: attendedClasses - 1,
      totalClasses: totalClasses - 1,
      lastUpdated: DateTime.now(),
    );
  }

  /// Quick action: Undo missed (-1 total if missed > 0).
  Subject undoMissed() {
    if (missedClasses <= 0 || totalClasses <= attendedClasses) return this;
    return copyWith(
      totalClasses: totalClasses - 1,
      lastUpdated: DateTime.now(),
    );
  }

  Subject copyWith({
    String? id,
    String? name,
    int? totalClasses,
    int? attendedClasses,
    double? customRequirement,
    bool clearCustomRequirement = false,
    int? colorValue,
    DateTime? lastUpdated,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      totalClasses: totalClasses ?? this.totalClasses,
      attendedClasses: attendedClasses ?? this.attendedClasses,
      customRequirement: clearCustomRequirement
          ? null
          : (customRequirement ?? this.customRequirement),
      colorValue: colorValue ?? this.colorValue,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'totalClasses': totalClasses,
      'attendedClasses': attendedClasses,
      'customRequirement': customRequirement,
      'colorValue': colorValue,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as String,
      name: json['name'] as String,
      totalClasses: (json['totalClasses'] as num).toInt(),
      attendedClasses: (json['attendedClasses'] as num).toInt(),
      customRequirement: json['customRequirement'] != null
          ? (json['customRequirement'] as num).toDouble()
          : null,
      colorValue: json['colorValue'] != null
          ? (json['colorValue'] as num).toInt()
          : null,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  static const List<Color> _palette = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF0EA5E9), // Sky
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFF14B8A6), // Teal
    Color(0xFFF97316), // Orange
  ];

  static int _defaultColorFor(String name) {
    if (name.isEmpty) return _palette[0].toARGB32();
    final index = name.codeUnits.fold<int>(0, (prev, curr) => prev + curr) %
        _palette.length;
    return _palette[index].toARGB32();
  }
}

