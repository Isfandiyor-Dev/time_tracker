import 'package:equatable/equatable.dart';

import '../../core/utils/time_math.dart';

class BreakPeriod extends Equatable {
  const BreakPeriod({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  int get seconds => end.difference(start).inSeconds.clamp(0, 1 << 31);

  @override
  List<Object?> get props => [start, end];
}

class TimeEntry extends Equatable {
  const TimeEntry({
    required this.id,
    required this.projectId,
    required this.hourlyRateSnapshot,
    required this.currencySnapshot,
    required this.start,
    required this.end,
    this.breaks = const [],
    this.notes = '',
    this.isPaid = false,
    required this.createdAt,
  });

  final int id;
  final int projectId;
  final double hourlyRateSnapshot;
  final String currencySnapshot;
  final DateTime start;
  final DateTime end;
  final List<BreakPeriod> breaks;
  final String notes;
  final bool isPaid;
  final DateTime createdAt;

  int get totalSeconds => workedSeconds(
    start: start,
    end: end,
    breaks: breaks.map((b) => (start: b.start, end: b.end)),
  );
  double get exactEarnings =>
      calculateExactEarnings(totalSeconds, hourlyRateSnapshot);

  TimeEntry copyWith({
    int? id,
    int? projectId,
    double? hourlyRateSnapshot,
    String? currencySnapshot,
    DateTime? start,
    DateTime? end,
    List<BreakPeriod>? breaks,
    String? notes,
    bool? isPaid,
  }) {
    return TimeEntry(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      hourlyRateSnapshot: hourlyRateSnapshot ?? this.hourlyRateSnapshot,
      currencySnapshot: currencySnapshot ?? this.currencySnapshot,
      start: start ?? this.start,
      end: end ?? this.end,
      breaks: breaks ?? this.breaks,
      notes: notes ?? this.notes,
      isPaid: isPaid ?? this.isPaid,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    projectId,
    hourlyRateSnapshot,
    currencySnapshot,
    start,
    end,
    breaks,
    notes,
    isPaid,
    createdAt,
  ];
}
