import '../entities/project.dart';
import '../entities/statistics.dart';
import '../entities/time_entry.dart';

abstract final class StatisticsCalculator {
  static StatisticsRange rangeFor(StatisticsPeriod period, DateTime anchor) {
    final day = DateTime(anchor.year, anchor.month, anchor.day);
    return switch (period) {
      StatisticsPeriod.week => () {
        final start = day.subtract(Duration(days: day.weekday - 1));
        return StatisticsRange(
          start: start,
          endExclusive: start.add(const Duration(days: 7)),
        );
      }(),
      StatisticsPeriod.month => StatisticsRange(
        start: DateTime(day.year, day.month),
        endExclusive: DateTime(day.year, day.month + 1),
      ),
      StatisticsPeriod.year => StatisticsRange(
        start: DateTime(day.year),
        endExclusive: DateTime(day.year + 1),
      ),
    };
  }

  static DateTime moveAnchor(
    StatisticsPeriod period,
    DateTime anchor,
    int direction,
  ) => switch (period) {
    StatisticsPeriod.week => anchor.add(Duration(days: 7 * direction)),
    StatisticsPeriod.month => DateTime(
      anchor.year,
      anchor.month + direction,
      1,
    ),
    StatisticsPeriod.year => DateTime(anchor.year + direction),
  };

  static List<TimeEntry> filteredEntries({
    required List<TimeEntry> entries,
    required StatisticsRange range,
    required int? projectId,
  }) {
    final result = entries
        .where(
          (entry) =>
              range.contains(entry.start) &&
              (projectId == null || entry.projectId == projectId),
        )
        .toList(growable: false);
    return [...result]..sort((a, b) => b.start.compareTo(a.start));
  }

  static StatisticsData calculate({
    required List<Project> projects,
    required List<TimeEntry> allEntries,
    required StatisticsPeriod period,
    required DateTime anchor,
    required int? projectId,
    required String displayCurrency,
    required Map<String, double> ratesToDisplayCurrency,
    StatisticsRange? rangeOverride,
    bool includeChart = true,
  }) {
    final range = rangeOverride ?? rangeFor(period, anchor);
    final entries = filteredEntries(
      entries: allEntries,
      range: range,
      projectId: projectId,
    );
    final projectById = {for (final project in projects) project.id: project};
    final missingCurrencies = <String>{};
    final originalTotals = <String, double>{};
    var totalSeconds = 0;
    var convertedTotal = 0.0;
    var convertedPaid = 0.0;
    var convertedUnpaid = 0.0;

    double? convert(TimeEntry entry) {
      final currency = entry.currencySnapshot.toUpperCase();
      final rate = currency == displayCurrency
          ? 1.0
          : ratesToDisplayCurrency[currency];
      if (rate == null || !rate.isFinite || rate <= 0) {
        missingCurrencies.add(currency);
        return null;
      }
      return entry.exactEarnings * rate;
    }

    for (final entry in entries) {
      totalSeconds += entry.totalSeconds;
      final currency = entry.currencySnapshot.toUpperCase();
      originalTotals.update(
        currency,
        (value) => value + entry.exactEarnings,
        ifAbsent: () => entry.exactEarnings,
      );
      final converted = convert(entry);
      if (converted != null) {
        convertedTotal += converted;
        if (entry.isPaid) {
          convertedPaid += converted;
        } else {
          convertedUnpaid += converted;
        }
      }
    }

    final buckets = includeChart
        ? _buildBuckets(period, range)
        : const <StatisticsRange>[];
    final chart = <StatisticsChartBucket>[];
    for (final bucket in buckets) {
      final bucketEntries = entries
          .where((entry) => bucket.contains(entry.start))
          .toList(growable: false);
      var seconds = 0;
      var earnings = 0.0;
      var complete = true;
      for (final entry in bucketEntries) {
        seconds += entry.totalSeconds;
        final converted = convert(entry);
        if (converted == null) {
          complete = false;
        } else {
          earnings += converted;
        }
      }
      chart.add(
        StatisticsChartBucket(
          start: bucket.start,
          endExclusive: bucket.endExclusive,
          seconds: seconds,
          earnings: complete ? earnings : null,
        ),
      );
    }

    final grouped = <DateTime, List<TimeEntry>>{};
    for (final entry in entries) {
      final date = DateTime(
        entry.start.year,
        entry.start.month,
        entry.start.day,
      );
      grouped.putIfAbsent(date, () => []).add(entry);
    }
    final groups = grouped.entries.map((group) {
      var seconds = 0;
      var earnings = 0.0;
      var complete = true;
      final items = <StatisticsEntryItem>[];
      for (final entry in group.value) {
        seconds += entry.totalSeconds;
        final converted = convert(entry);
        if (converted == null) {
          complete = false;
        } else {
          earnings += converted;
        }
        final project = projectById[entry.projectId];
        if (project != null) {
          items.add(
            StatisticsEntryItem(
              entry: entry,
              project: project,
              convertedEarnings: converted,
            ),
          );
        }
      }
      return StatisticsEntryGroup(
        date: group.key,
        items: items,
        totalSeconds: seconds,
        convertedEarnings: complete ? earnings : null,
      );
    }).toList()..sort((a, b) => b.date.compareTo(a.date));

    final conversionComplete = missingCurrencies.isEmpty;
    return StatisticsData(
      range: range,
      entries: entries,
      totalSeconds: totalSeconds,
      convertedEarnings: conversionComplete ? convertedTotal : null,
      paidEarnings: conversionComplete ? convertedPaid : null,
      unpaidEarnings: conversionComplete ? convertedUnpaid : null,
      originalCurrencyTotals: Map.unmodifiable(originalTotals),
      chartBuckets: List.unmodifiable(chart),
      groups: List.unmodifiable(groups),
      missingCurrencies: Set.unmodifiable(missingCurrencies),
    );
  }

  static List<StatisticsRange> _buildBuckets(
    StatisticsPeriod period,
    StatisticsRange range,
  ) => switch (period) {
    StatisticsPeriod.week => List.generate(7, (index) {
      final start = range.start.add(Duration(days: index));
      return StatisticsRange(
        start: start,
        endExclusive: start.add(const Duration(days: 1)),
      );
    }),
    StatisticsPeriod.month => () {
      final result = <StatisticsRange>[];
      var start = range.start;
      while (start.isBefore(range.endExclusive)) {
        final candidate = start.add(const Duration(days: 7));
        final end = candidate.isAfter(range.endExclusive)
            ? range.endExclusive
            : candidate;
        result.add(StatisticsRange(start: start, endExclusive: end));
        start = end;
      }
      return result;
    }(),
    StatisticsPeriod.year => List.generate(12, (index) {
      final start = DateTime(range.start.year, index + 1);
      return StatisticsRange(
        start: start,
        endExclusive: DateTime(range.start.year, index + 2),
      );
    }),
  };
}
