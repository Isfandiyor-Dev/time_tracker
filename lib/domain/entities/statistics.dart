import 'package:equatable/equatable.dart';

import 'project.dart';
import 'time_entry.dart';

enum StatisticsMetric { earnings, time }

enum StatisticsPeriod { week, month, year }

enum ExchangeRateStatus { idle, loading, ready, unavailable }

class StatisticsRange extends Equatable {
  const StatisticsRange({required this.start, required this.endExclusive});

  final DateTime start;
  final DateTime endExclusive;

  bool contains(DateTime value) =>
      !value.isBefore(start) && value.isBefore(endExclusive);

  @override
  List<Object?> get props => [start, endExclusive];
}

class StatisticsChartBucket extends Equatable {
  const StatisticsChartBucket({
    required this.start,
    required this.endExclusive,
    required this.seconds,
    required this.earnings,
  });

  final DateTime start;
  final DateTime endExclusive;
  final int seconds;
  final double? earnings;

  @override
  List<Object?> get props => [start, endExclusive, seconds, earnings];
}

class StatisticsEntryItem extends Equatable {
  const StatisticsEntryItem({
    required this.entry,
    required this.project,
    required this.convertedEarnings,
  });

  final TimeEntry entry;
  final Project project;
  final double? convertedEarnings;

  @override
  List<Object?> get props => [entry, project, convertedEarnings];
}

class StatisticsEntryGroup extends Equatable {
  const StatisticsEntryGroup({
    required this.date,
    required this.items,
    required this.totalSeconds,
    required this.convertedEarnings,
  });

  final DateTime date;
  final List<StatisticsEntryItem> items;
  final int totalSeconds;
  final double? convertedEarnings;

  @override
  List<Object?> get props => [date, items, totalSeconds, convertedEarnings];
}

class StatisticsData extends Equatable {
  const StatisticsData({
    required this.range,
    required this.entries,
    required this.totalSeconds,
    required this.convertedEarnings,
    required this.paidEarnings,
    required this.unpaidEarnings,
    required this.originalCurrencyTotals,
    required this.chartBuckets,
    required this.groups,
    required this.missingCurrencies,
  });

  final StatisticsRange range;
  final List<TimeEntry> entries;
  final int totalSeconds;
  final double? convertedEarnings;
  final double? paidEarnings;
  final double? unpaidEarnings;
  final Map<String, double> originalCurrencyTotals;
  final List<StatisticsChartBucket> chartBuckets;
  final List<StatisticsEntryGroup> groups;
  final Set<String> missingCurrencies;

  bool get isEmpty => entries.isEmpty;
  bool get conversionComplete => missingCurrencies.isEmpty;

  @override
  List<Object?> get props => [
    range,
    entries,
    totalSeconds,
    convertedEarnings,
    paidEarnings,
    unpaidEarnings,
    originalCurrencyTotals,
    chartBuckets,
    groups,
    missingCurrencies,
  ];
}
