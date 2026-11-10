import '../entities/running_timer.dart';

abstract interface class TimerService {
  Future<void> setLocale(String languageCode);
  Future<bool> ensureNotificationPermission();
  Future<void> start(RunningTimer timer);
  Future<void> toggleBreak();
  Future<void> stop();
  Future<RunningTimer?> restore();
  Future<RunningTimer?> consumePendingPunchOut();
  Future<bool> consumeOpenTimerRequest();
}
