import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracker/core/utils/formatters.dart';
import 'package:time_tracker/core/utils/time_math.dart';
import 'package:time_tracker/domain/entities/running_timer.dart';
import 'package:time_tracker/domain/entities/time_entry.dart';

void main() {
  group('second-precision earnings', () {
    test('keeps the exact value until presentation rounding', () {
      final exact = calculateExactEarnings(1, 100);

      expect(exact, closeTo(0.0277777777777778, 1e-15));
      expect(roundCurrency(exact), 0.03);
    });

    test('subtracts breaks in seconds', () {
      final start = DateTime(2026, 7, 30, 9);
      final end = DateTime(2026, 7, 30, 10);
      final seconds = workedSeconds(
        start: start,
        end: end,
        breaks: [
          (
            start: DateTime(2026, 7, 30, 9, 10, 5),
            end: DateTime(2026, 7, 30, 9, 15, 10),
          ),
        ],
      );

      expect(seconds, 3295);
    });

    test('entry uses its historical rate and currency snapshot', () {
      final entry = TimeEntry(
        id: 1,
        projectId: 7,
        hourlyRateSnapshot: 12.5,
        currencySnapshot: 'USD',
        start: DateTime(2026, 1, 1, 10),
        end: DateTime(2026, 1, 1, 12),
        createdAt: DateTime(2026, 1, 1),
      );

      expect(entry.totalSeconds, 7200);
      expect(entry.exactEarnings, 25);
      expect(entry.currencySnapshot, 'USD');
    });
  });

  test('active break has its own stopwatch and does not count as work', () {
    final timer = RunningTimer(
      projectId: 1,
      projectName: 'Test',
      currency: 'UZS',
      hourlyRate: 100000,
      startedAt: DateTime(2026, 1, 1, 10),
      breakStartedAt: DateTime(2026, 1, 1, 10, 20),
    );
    final now = DateTime(2026, 1, 1, 11);

    expect(timer.elapsedSeconds(now), 1200);
    expect(timer.activeBreakElapsedSeconds(now), 2400);
    expect(timer.stopwatchSeconds(now), 2400);
  });

  test('stopwatch returns to worked time after a break ends', () {
    final timer = RunningTimer(
      projectId: 1,
      projectName: 'Test',
      currency: 'UZS',
      hourlyRate: 100000,
      startedAt: DateTime(2026, 1, 1, 10),
      completedBreaks: [
        BreakPeriod(
          start: DateTime(2026, 1, 1, 10, 20),
          end: DateTime(2026, 1, 1, 11),
        ),
      ],
    );
    final now = DateTime(2026, 1, 1, 11, 10);

    expect(timer.elapsedSeconds(now), 1800);
    expect(timer.stopwatchSeconds(now), 1800);
  });

  test('editor date and time follow the reference format', () {
    final value = DateTime(2026, 7, 30, 9, 27);

    expect(formatDate(value), '30.07.2026');
    expect(formatTime(value), '9:27');
  });
}
