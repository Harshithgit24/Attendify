/// Represents the attendance health status for visual styling and indicators.
enum AttendanceStatus {
  /// Attendance is equal to or above the required threshold (Green)
  safe,

  /// Attendance is within 5% below the required threshold (Yellow / Warning)
  warning,

  /// Attendance is more than 5% below the required threshold (Red / Shortage)
  critical,

  /// No classes have been held yet (Neutral / Info)
  notStarted,
}

/// Pure utility class for all attendance and future prediction calculations.
class AttendanceCalculator {
  /// Calculates attendance percentage.
  /// Returns 100.0 if total classes is 0.
  static double calculatePercentage(int attended, int total) {
    if (total <= 0) return 100.0;
    if (attended <= 0) return 0.0;
    if (attended >= total) return 100.0;
    return (attended / total) * 100.0;
  }

  /// Calculates number of missed classes.
  static int calculateMissed(int attended, int total) {
    if (total <= 0) return 0;
    final missed = total - attended;
    return missed < 0 ? 0 : missed;
  }

  /// Determines the status level (Safe, Warning, Critical, NotStarted)
  /// based on attendance percentage and required threshold.
  static AttendanceStatus getStatus({
    required int attended,
    required int total,
    required double requiredPercentage,
  }) {
    if (total <= 0) {
      return AttendanceStatus.notStarted;
    }

    final currentPercentage = calculatePercentage(attended, total);

    if (currentPercentage >= requiredPercentage) {
      return AttendanceStatus.safe;
    } else if (currentPercentage >= (requiredPercentage - 5.0)) {
      return AttendanceStatus.warning;
    } else {
      return AttendanceStatus.critical;
    }
  }

  /// Calculates how many future consecutive classes a student can miss (bunk)
  /// without falling below the required attendance percentage [requiredPercentage].
  ///
  /// Mathematical formula:
  /// (attended / (total + m)) >= R
  /// m <= (attended / R) - total
  /// m = floor(attended / R - total)
  ///
  /// Returns 0 if already below or right on the boundary.
  static int calculateClassesCanMiss({
    required int attended,
    required int total,
    required double requiredPercentage,
  }) {
    if (total <= 0) return 0;

    final double r = requiredPercentage / 100.0;
    if (r <= 0) return 999; // Can miss effectively unlimited if required is 0%
    if (r > 1.0) return 0;

    final current = calculatePercentage(attended, total);
    if (current < requiredPercentage) {
      return 0; // Already below requirement
    }

    // Formula: floor(attended / r - total)
    // To prevent floating-point inaccuracy (e.g. 32 / 0.75 - 40 = 2.6666667)
    final double maxMiss = (attended / r) - total;
    if (maxMiss <= 0.00001) {
      return 0;
    }

    return maxMiss.floor();
  }

  /// Calculates how many consecutive classes a student must attend
  /// to reach or exceed the required attendance percentage [requiredPercentage].
  ///
  /// Mathematical formula:
  /// ((attended + c) / (total + c)) >= R
  /// attended + c >= R * total + R * c
  /// c * (1 - R) >= R * total - attended
  /// c >= (R * total - attended) / (1 - R)
  /// c = ceil((R * total - attended) / (1 - R))
  ///
  /// Returns 0 if already meeting or exceeding requirement.
  /// Returns -1 if requirement is 100% and attended < total (mathematically impossible to recover).
  static int calculateClassesToAttend({
    required int attended,
    required int total,
    required double requiredPercentage,
  }) {
    if (total <= 0) return 0;

    final current = calculatePercentage(attended, total);
    if (current >= requiredPercentage) {
      return 0; // Already safe
    }

    final double r = requiredPercentage / 100.0;
    if (r >= 1.0) {
      // If 100% is required and at least 1 class was missed, you can never achieve 100%
      return -1;
    }

    final double needed = (r * total - attended) / (1.0 - r);
    if (needed <= 0.00001) {
      return 0;
    }

    return needed.ceil();
  }

  /// Calculates what the attendance percentage will become
  /// after attending the next [nextClasses] consecutive classes.
  static double predictAttendanceAfterAttending({
    required int attended,
    required int total,
    required int nextClasses,
  }) {
    if (nextClasses < 0) nextClasses = 0;
    final newTotal = total + nextClasses;
    final newAttended = attended + nextClasses;
    return calculatePercentage(newAttended, newTotal);
  }

  /// Calculates what the attendance percentage will become
  /// after missing the next [nextClasses] consecutive classes.
  static double predictAttendanceAfterMissing({
    required int attended,
    required int total,
    required int nextClasses,
  }) {
    if (nextClasses < 0) nextClasses = 0;
    final newTotal = total + nextClasses;
    return calculatePercentage(attended, newTotal);
  }

  /// Formats double percentage cleanly, e.g. "75%", "82.5%".
  static String formatPercentage(double percentage) {
    if (percentage.isNaN || percentage.isInfinite) return '0%';
    if (percentage == percentage.roundToDouble()) {
      return '${percentage.toInt()}%';
    }
    return '${percentage.toStringAsFixed(1)}%';
  }
}
