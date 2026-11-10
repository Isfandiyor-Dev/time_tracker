import 'package:flutter/services.dart';

import '../../domain/entities/running_timer.dart';
import '../../domain/entities/time_entry.dart';
import '../../domain/services/timer_service.dart';

class PlatformTimerService implements TimerService {
  static const _channel = MethodChannel('time_tracker/foreground_timer');

  @override
  Future<void> setLocale(String languageCode) async {
    try {
      await _channel.invokeMethod<void>('setLocale', languageCode);
    } on MissingPluginException {
      // No-op on unsupported platforms.
    }
  }

  @override
  Future<bool> ensureNotificationPermission() async {
    try {
      return await _channel.invokeMethod<bool>(
            'ensureNotificationPermission',
          ) ??
          false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<void> start(RunningTimer timer) async {
    try {
      await _channel.invokeMethod<void>('start', _toMap(timer));
    } on MissingPluginException {
      // The in-app timer remains available on platforms without a native service.
    }
  }

  @override
  Future<void> toggleBreak() async {
    try {
      await _channel.invokeMethod<void>('toggleBreak');
    } on MissingPluginException {
      // No-op on unsupported platforms.
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _channel.invokeMethod<void>('stop');
    } on MissingPluginException {
      // No-op on unsupported platforms.
    }
  }

  @override
  Future<RunningTimer?> restore() => _read('restore');

  @override
  Future<RunningTimer?> consumePendingPunchOut() =>
      _read('consumePendingPunchOut');

  @override
  Future<bool> consumeOpenTimerRequest() async {
    try {
      return await _channel.invokeMethod<bool>('consumeOpenTimerRequest') ??
          false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<RunningTimer?> _read(String method) async {
    try {
      final raw = await _channel.invokeMapMethod<String, Object?>(method);
      return raw == null ? null : _fromMap(raw);
    } on MissingPluginException {
      return null;
    }
  }

  Map<String, Object?> _toMap(RunningTimer timer) => {
    'projectId': timer.projectId,
    'projectName': timer.projectName,
    'currency': timer.currency,
    'hourlyRate': timer.hourlyRate,
    'startedAt': timer.startedAt.millisecondsSinceEpoch,
    'breakStartedAt': timer.breakStartedAt?.millisecondsSinceEpoch,
    'stoppedAt': timer.stoppedAt?.millisecondsSinceEpoch,
    'breaks': timer.completedBreaks
        .map(
          (b) => {
            'start': b.start.millisecondsSinceEpoch,
            'end': b.end.millisecondsSinceEpoch,
          },
        )
        .toList(),
  };

  RunningTimer _fromMap(Map<String, Object?> raw) {
    final breakValues = (raw['breaks'] as List<Object?>? ?? const []);
    final breaks = breakValues.map((value) {
      final map = Map<Object?, Object?>.from(value! as Map);
      return BreakPeriod(
        start: DateTime.fromMillisecondsSinceEpoch(
          (map['start'] as num).toInt(),
        ),
        end: DateTime.fromMillisecondsSinceEpoch((map['end'] as num).toInt()),
      );
    }).toList();
    final breakStart = raw['breakStartedAt'] as num?;
    final stoppedAt = raw['stoppedAt'] as num?;
    return RunningTimer(
      projectId: (raw['projectId'] as num).toInt(),
      projectName: raw['projectName']! as String,
      currency: raw['currency']! as String,
      hourlyRate: (raw['hourlyRate'] as num).toDouble(),
      startedAt: DateTime.fromMillisecondsSinceEpoch(
        (raw['startedAt'] as num).toInt(),
      ),
      completedBreaks: breaks,
      breakStartedAt: breakStart == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(breakStart.toInt()),
      stoppedAt: stoppedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(stoppedAt.toInt()),
    );
  }
}
