import 'package:equatable/equatable.dart';

import 'time_entry.dart';

class RunningTimer extends Equatable {
  const RunningTimer({
    required this.projectId,
    required this.projectName,
    required this.currency,
    required this.hourlyRate,
    required this.startedAt,
    this.completedBreaks = const [],
    this.breakStartedAt,
    this.stoppedAt,
  });

  final int projectId;
  final String projectName;
  final String currency;
  final double hourlyRate;
  final DateTime startedAt;
  final List<BreakPeriod> completedBreaks;
  final DateTime? breakStartedAt;
  final DateTime? stoppedAt;

  bool get isOnBreak => breakStartedAt != null;

  int elapsedSeconds(DateTime now) {
    final effectiveNow = stoppedAt ?? now;
    final completed = completedBreaks.fold<int>(0, (sum, b) => sum + b.seconds);
    final currentBreak = breakStartedAt == null
        ? 0
        : effectiveNow.difference(breakStartedAt!).inSeconds;
    return (effectiveNow.difference(startedAt).inSeconds -
            completed -
            currentBreak)
        .clamp(0, 1 << 31);
  }

  int activeBreakElapsedSeconds(DateTime now) {
    final breakStart = breakStartedAt;
    if (breakStart == null) return 0;

    final effectiveNow = stoppedAt ?? now;
    return effectiveNow.difference(breakStart).inSeconds.clamp(0, 1 << 31);
  }

  /// The value shown by stopwatch UIs.
  ///
  /// While a break is active, the stopwatch starts from zero and measures that
  /// break. Once the break ends, it switches back to total worked time.
  int stopwatchSeconds(DateTime now) =>
      isOnBreak ? activeBreakElapsedSeconds(now) : elapsedSeconds(now);

  RunningTimer copyWith({
    String? projectName,
    List<BreakPeriod>? completedBreaks,
    DateTime? breakStartedAt,
    bool clearBreak = false,
    DateTime? stoppedAt,
  }) {
    return RunningTimer(
      projectId: projectId,
      projectName: projectName ?? this.projectName,
      currency: currency,
      hourlyRate: hourlyRate,
      startedAt: startedAt,
      completedBreaks: completedBreaks ?? this.completedBreaks,
      breakStartedAt: clearBreak ? null : breakStartedAt ?? this.breakStartedAt,
      stoppedAt: stoppedAt ?? this.stoppedAt,
    );
  }

  @override
  List<Object?> get props => [
    projectId,
    projectName,
    currency,
    hourlyRate,
    startedAt,
    completedBreaks,
    breakStartedAt,
    stoppedAt,
  ];
}
