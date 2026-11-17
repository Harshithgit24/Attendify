import 'package:flutter/material.dart';
import 'attendance_calculator.dart';

/// App theme definitions and color constants for Attendify.
class AppTheme {
  // Status Colors
  static const Color safeGreen = Color(0xFF10B981); // Emerald
  static const Color safeGreenLight = Color(0xFFE8FDF3);
  static const Color safeGreenDark = Color(0xFF064E3B);

  static const Color warningYellow = Color(0xFFF59E0B); // Warm Amber
  static const Color warningYellowLight = Color(0xFFFFFBEB);
  static const Color warningYellowDark = Color(0xFF78350F);

  static const Color criticalRed = Color(0xFFEF4444); // Crimson
  static const Color criticalRedLight = Color(0xFFFEF2F2);
  static const Color criticalRedDark = Color(0xFF7F1D1D);

  static const Color neutralGray = Color(0xFF6B7280);

  // Brand Accents
  static const Color primaryBlue = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryLight = Color(0xFF6366F1);

  /// Helper to get color for a specific attendance status.
  static Color getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.safe:
        return safeGreen;
      case AttendanceStatus.warning:
        return warningYellow;
      case AttendanceStatus.critical:
        return criticalRed;
      case AttendanceStatus.notStarted:
        return neutralGray;
    }
  }

  /// Helper to get soft background container color for badges/chips.
  static Color getStatusBackgroundColor(
    AttendanceStatus status,
    bool isDarkMode,
  ) {
    if (isDarkMode) {
      switch (status) {
        case AttendanceStatus.safe:
          return safeGreenDark.withValues(alpha: 0.35);
        case AttendanceStatus.warning:
          return warningYellowDark.withValues(alpha: 0.35);
        case AttendanceStatus.critical:
          return criticalRedDark.withValues(alpha: 0.35);
        case AttendanceStatus.notStarted:
          return Colors.white.withValues(alpha: 0.08);
      }
    } else {
      switch (status) {
        case AttendanceStatus.safe:
          return safeGreenLight;
        case AttendanceStatus.warning:
          return warningYellowLight;
        case AttendanceStatus.critical:
          return criticalRedLight;
        case AttendanceStatus.notStarted:
          return const Color(0xFFF3F4F6);
      }
    }
  }

  /// Light theme definition
  static ThemeData get lightTheme {
    const background = Color(0xFFF8FAFC); // Slate 50
    const surface = Colors.white;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
        surface: surface,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: Color(0xFF0F172A)),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }

  /// Dark theme definition
  static ThemeData get darkTheme {
    const background = Color(0xFF0F172A); // Slate 900
    const surface = Color(0xFF1E293B); // Slate 800

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.dark,
        surface: surface,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Color(0xFFF8FAFC),
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: Color(0xFFF8FAFC)),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF334155), width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0F172A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryLight, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryLight,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }
}
