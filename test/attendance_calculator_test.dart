import 'package:flutter_test/flutter_test.dart';
import 'package:attendify/utils/attendance_calculator.dart';

void main() {
  group('AttendanceCalculator Tests', () {
    test('User exact example verification (40 total, 32 attended, 75% req)', () {
      const total = 40;
      const attended = 32;
      const requiredPercentage = 75.0;

      // 1. Missed classes
      final missed = AttendanceCalculator.calculateMissed(attended, total);
      expect(missed, equals(8));

      // 2. Attendance percentage
      final percentage = AttendanceCalculator.calculatePercentage(attended, total);
      expect(percentage, equals(80.0));

      // 3. Status is safe
      final status = AttendanceCalculator.getStatus(
        attended: attended,
        total: total,
        requiredPercentage: requiredPercentage,
      );
      expect(status, equals(AttendanceStatus.safe));

      // 4. Can miss classes
      // floor(32 / 0.75 - 40) = floor(42.666 - 40) = 2
      final canMiss = AttendanceCalculator.calculateClassesCanMiss(
        attended: attended,
        total: total,
        requiredPercentage: requiredPercentage,
      );
      expect(canMiss, equals(2));

      // Check if missing 2 keeps attendance >= 75%:
      // 32 / (40 + 2) = 32 / 42 = 76.19% >= 75%
      expect(AttendanceCalculator.calculatePercentage(32, 42), greaterThanOrEqualTo(75.0));

      // Check if missing 3 drops below 75%:
      // 32 / (40 + 3) = 32 / 43 = 74.41% < 75%
      expect(AttendanceCalculator.calculatePercentage(32, 43), lessThan(75.0));

      // 5. Classes to attend (should be 0 since already at 80% >= 75%)
      final toAttend = AttendanceCalculator.calculateClassesToAttend(
        attended: attended,
        total: total,
        requiredPercentage: requiredPercentage,
      );
      expect(toAttend, equals(0));

      // 6. Next 5 classes attended:
      // (32 + 5) / (40 + 5) = 37 / 45 = 82.222...%
      final after5 = AttendanceCalculator.predictAttendanceAfterAttending(
        attended: attended,
        total: total,
        nextClasses: 5,
      );
      expect(after5, closeTo(82.22, 0.01));
    });

    test('Shortage recovery calculation (Total: 20, Attended: 12, Req: 75%)', () {
      const total = 20;
      const attended = 12; // 60%
      const requiredPercentage = 75.0;

      final percentage = AttendanceCalculator.calculatePercentage(attended, total);
      expect(percentage, equals(60.0));

      final status = AttendanceCalculator.getStatus(
        attended: attended,
        total: total,
        requiredPercentage: requiredPercentage,
      );
      expect(status, equals(AttendanceStatus.critical));

      final canMiss = AttendanceCalculator.calculateClassesCanMiss(
        attended: attended,
        total: total,
        requiredPercentage: requiredPercentage,
      );
      expect(canMiss, equals(0));

      // Needed: ceil((0.75 * 20 - 12) / (1 - 0.75)) = ceil((15 - 12) / 0.25) = 12
      final toAttend = AttendanceCalculator.calculateClassesToAttend(
        attended: attended,
        total: total,
        requiredPercentage: requiredPercentage,
      );
      expect(toAttend, equals(12));

      // Verify that after 12 classes attended, percentage is exactly 75%
      final after12 = AttendanceCalculator.predictAttendanceAfterAttending(
        attended: attended,
        total: total,
        nextClasses: 12,
      );
      expect(after12, equals(75.0));
    });

    test('Warning threshold check (within 5% below target)', () {
      // 72% with 75% required -> warning
      final status = AttendanceCalculator.getStatus(
        attended: 72,
        total: 100,
        requiredPercentage: 75.0,
      );
      expect(status, equals(AttendanceStatus.warning));
    });

    test('Edge cases (0 total classes, 100% required)', () {
      expect(AttendanceCalculator.calculatePercentage(0, 0), equals(100.0));
      expect(AttendanceCalculator.calculateMissed(0, 0), equals(0));
      expect(
        AttendanceCalculator.getStatus(
          attended: 0,
          total: 0,
          requiredPercentage: 75.0,
        ),
        equals(AttendanceStatus.notStarted),
      );

      // 100% requirement with 1 missed class
      final impossible = AttendanceCalculator.calculateClassesToAttend(
        attended: 9,
        total: 10,
        requiredPercentage: 100.0,
      );
      expect(impossible, equals(-1));
    });
  });
}

