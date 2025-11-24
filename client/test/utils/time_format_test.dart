import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:client/utils/time_format.dart';
import 'package:client/l10n/app_localizations.dart';

void main() {
  group('Duration.format', () {
    test('test duation format', () {
      var d = const Duration(
          days: 1, hours: 2, minutes: 3, seconds: 4, milliseconds: 567);
      expect(d.format(), "26h3m4.57s");

      d = const Duration(days: 1);
      expect(d.format(), "24h");

      d = const Duration(hours: 1);
      expect(d.format(), "1h");

      d = const Duration(minutes: 1);
      expect(d.format(), "1m");

      d = const Duration(seconds: 1);
      expect(d.format(), "1.00s");

      d = const Duration(milliseconds: 1);
      expect(d.format(), "0.00s");

      d = const Duration(milliseconds: 10);
      expect(d.format(), "0.01s");

      d = const Duration(microseconds: 1);
      expect(d.format(), "0.00s");

      d = const Duration(microseconds: 999);
      expect(d.format(), "0.00s");

      d = const Duration(hours: -1);
      expect(d.format(), "0.00s");
    });
  });

  group('DateTime.formatFullDateTime', () {
    testWidgets('formats date time correctly with English locale',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) {
              final dateTime = DateTime(2024, 1, 15, 14, 30, 45);
              final formatted = dateTime.formatFullDateTime(context);
              expect(formatted, 'January 15, 2024 14:30');
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('formats with zero padding with English locale',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) {
              final dateTime = DateTime(2024, 1, 5, 9, 5, 3);
              final formatted = dateTime.formatFullDateTime(context);
              expect(formatted, 'January 5, 2024 09:05');
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('formats end of year correctly with English locale',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) {
              final dateTime = DateTime(2024, 12, 31, 23, 59, 59);
              final formatted = dateTime.formatFullDateTime(context);
              expect(formatted, 'December 31, 2024 23:59');
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('formats date time correctly with Chinese locale',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('zh'),
          home: Builder(
            builder: (context) {
              final dateTime = DateTime(2024, 1, 15, 14, 30, 45);
              final formatted = dateTime.formatFullDateTime(context);
              expect(formatted, '2024年1月15日 14:30');
              return Container();
            },
          ),
        ),
      );
    });

    test('uses default English locale when context is null', () {
      final dateTime = DateTime(2024, 1, 15, 14, 30, 45);
      final formatted = dateTime.formatFullDateTime();
      expect(formatted, 'January 15, 2024 14:30');
    });
  });

  group('DateTime.formatDateTime', () {
    testWidgets('formats date time correctly', (WidgetTester tester) async {
      final testCases = [
        // Today
        {
          'date': DateTime(2024, 1, 15, 14, 30),
          'now': DateTime(2024, 1, 15, 14, 30),
          'expected': 'Today 14:30',
        },
        {
          'date': DateTime(2024, 1, 15, 0, 0),
          'now': DateTime(2024, 1, 15, 14, 30),
          'expected': 'Today 00:00',
        },
        {
          'date': DateTime(2024, 1, 15, 23, 59),
          'now': DateTime(2024, 1, 15, 14, 30),
          'expected': 'Today 23:59',
        },
        // Yesterday
        {
          'date': DateTime(2024, 1, 14, 10, 20),
          'now': DateTime(2024, 1, 15, 14, 30),
          'expected': 'Yesterday 10:20',
        },
        {
          'date': DateTime(2024, 1, 14, 0, 0),
          'now': DateTime(2024, 1, 15, 14, 30),
          'expected': 'Yesterday 00:00',
        },
        // Within 7 days - weekdays
        {
          'date': DateTime(2024, 1, 13, 10, 30), // Saturday, 2 days ago
          'now': DateTime(2024, 1, 15, 14, 30),
          'expected': 'Sat 10:30',
        },
        {
          'date': DateTime(2024, 1, 12, 10, 30), // Friday, 3 days ago
          'now': DateTime(2024, 1, 15, 14, 30),
          'expected': 'Fri 10:30',
        },
        {
          'date': DateTime(2024, 1, 11, 9, 15), // Thursday, 4 days ago
          'now': DateTime(2024, 1, 15, 14, 30),
          'expected': 'Thu 09:15',
        },
        {
          'date': DateTime(2024, 1, 10, 8, 5), // Wednesday, 5 days ago
          'now': DateTime(2024, 1, 15, 14, 30),
          'expected': 'Wed 08:05',
        },
        {
          'date': DateTime(2024, 1, 9, 7, 0), // Tuesday, 6 days ago
          'now': DateTime(2024, 1, 15, 14, 30),
          'expected': 'Tue 07:00',
        },
        // Boundary: exactly 7 days ago (should show date format)
        {
          'date': DateTime(2024, 1, 8, 10, 30), // Monday, 7 days ago
          'now': DateTime(2024, 1, 15, 14, 30),
          'expected': '2024-01-08 10:30',
        },
        // More than 7 days
        {
          'date': DateTime(2024, 1, 1, 10, 30),
          'now': DateTime(2024, 1, 15, 14, 30),
          'expected': '2024-01-01 10:30',
        },
        {
          'date': DateTime(2023, 12, 25, 23, 59),
          'now': DateTime(2024, 1, 15, 14, 30),
          'expected': '2023-12-25 23:59',
        },
        // Cross month but within 7 days
        {
          'date': DateTime(2024, 1, 1, 12, 0), // Monday, 14 days ago (more than 7)
          'now': DateTime(2024, 1, 15, 14, 30),
          'expected': '2024-01-01 12:00',
        },
        // Edge case: same time different day
        {
          'date': DateTime(2024, 1, 15, 14, 30, 1), // 1 second later, still today
          'now': DateTime(2024, 1, 15, 14, 30),
          'expected': 'Today 14:30',
        },
      ];

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              for (final testCase in testCases) {
                final date = testCase['date'] as DateTime;
                final now = testCase['now'] as DateTime;
                final expected = testCase['expected'] as String;
                final formatted = date.formatDateTime(context, now: now);
                expect(formatted, expected);
              }
              return Container();
            },
          ),
        ),
      );
    });
  });
}

