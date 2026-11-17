import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:attendify/main.dart';
import 'package:attendify/providers/attendance_provider.dart';
import 'package:attendify/providers/theme_provider.dart';
import 'package:attendify/services/storage_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Attendify dashboard loads and displays summary & demo subjects',
      (WidgetTester tester) async {
    final storageService = await StorageService.init();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider(storageService)),
          ChangeNotifierProvider(
              create: (_) => AttendanceProvider(storageService)),
        ],
        child: const AttendifyApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify app title
    expect(find.text('Attendify'), findsOneWidget);

    // Verify Overall Attendance card
    expect(find.text('Overall Attendance'), findsOneWidget);

    // Verify filter chips exist
    expect(find.textContaining('All ('), findsOneWidget);
    expect(find.textContaining('Safe ('), findsOneWidget);
    expect(find.textContaining('Warning ('), findsOneWidget);
    expect(find.textContaining('Shortage ('), findsOneWidget);

    // Verify Add Subject FAB
    expect(find.text('Add Subject'), findsOneWidget);
  });

  testWidgets('Add a new subject with 40 total and 32 attended (80%)',
      (WidgetTester tester) async {
    final storageService = await StorageService.init();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider(storageService)),
          ChangeNotifierProvider(
              create: (_) => AttendanceProvider(storageService)),
        ],
        child: const AttendifyApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Tap Add Subject FAB
    await tester.tap(find.text('Add Subject'));
    await tester.pumpAndSettle();

    // Fill form fields
    final textFields = find.byType(TextFormField);
    expect(textFields, findsNWidgets(3));

    // Name
    await tester.enterText(textFields.at(0), 'Artificial Intelligence');
    // Total Classes
    await tester.enterText(textFields.at(1), '40');
    // Attended Classes
    await tester.enterText(textFields.at(2), '32');
    await tester.pumpAndSettle();

    // Verify live preview in modal
    expect(find.text('Missed Classes: 8'), findsOneWidget);
    expect(find.text('80%'), findsAtLeastNWidgets(1));

    // Tap submit button in modal
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add Subject'));
    await tester.pumpAndSettle();

    // Verify subject card is added to dashboard
    expect(find.text('Artificial Intelligence'), findsOneWidget);
    expect(find.text('Can miss 2 more classes safely.'), findsOneWidget);
  });

  testWidgets('Quick Attended (+1) button updates subject counts',
      (WidgetTester tester) async {
    final storageService = await StorageService.init();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider(storageService)),
          ChangeNotifierProvider(
              create: (_) => AttendanceProvider(storageService)),
        ],
        child: const AttendifyApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Tap the first 'Attended' button on a card
    final attendedButtons = find.widgetWithText(ElevatedButton, 'Attended');
    expect(attendedButtons, findsWidgets);

    await tester.tap(attendedButtons.first);
    await tester.pumpAndSettle();

    // Verify total classes incremented
    expect(find.textContaining('/ 41 classes'), findsOneWidget);
  });
}
