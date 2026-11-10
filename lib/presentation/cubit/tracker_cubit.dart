import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/localized_exception.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/running_timer.dart';
import '../../domain/entities/time_entry.dart';
import '../../domain/repositories/tracker_repository.dart';
import '../../domain/services/timer_service.dart';
import '../../generated/locale_keys.g.dart';

part 'tracker_state.dart';

class TrackerCubit extends Cubit<TrackerState> {
  TrackerCubit(this._repository, this._timerService)
    : super(const TrackerState());

  final TrackerRepository _repository;
  final TimerService _timerService;
  Timer? _ticker;

  Future<void> syncNotificationLocale(String languageCode) =>
      _timerService.setLocale(languageCode);

  Future<void> initialize() async {
    try {
      final projects = await _repository.getProjects();
      final entries = await _repository.getEntries();
      final pending = await _timerService.consumePendingPunchOut();
      final restored = pending == null ? await _timerService.restore() : null;
      emit(
        state.copyWith(
          status: TrackerStatus.ready,
          projects: projects,
          entries: entries,
          selectedProjectId: projects.isEmpty ? null : projects.first.id,
          clearSelectedProject: projects.isEmpty,
          runningTimer: restored,
          clearRunningTimer: restored == null,
          now: DateTime.now(),
        ),
      );
      if (restored != null) _startTicker();
      if (pending != null) await _storePendingPunchOut(pending);
    } catch (_) {
      emit(
        state.copyWith(
          status: TrackerStatus.failure,
          errorMessage: LocaleKeys.errors_loadFailed,
        ),
      );
    }
  }

  Future<void> refresh() async {
    final projects = await _repository.getProjects();
    final entries = await _repository.getEntries();
    var selected = state.selectedProjectId;
    if (!projects.any((project) => project.id == selected)) {
      selected = projects.isEmpty ? null : projects.first.id;
    }
    emit(
      state.copyWith(
        projects: projects,
        entries: entries,
        selectedProjectId: selected,
        clearSelectedProject: selected == null,
      ),
    );
  }

  void selectProject(int id) {
    if (state.isSelecting) return;
    emit(state.copyWith(selectedProjectId: id));
  }

  Future<Project> saveProject({
    int id = 0,
    required String name,
    required String currency,
    required double hourlyRate,
  }) async {
    final existing = state.projects.where((item) => item.id == id).firstOrNull;
    final saved = await _repository.saveProject(
      Project(
        id: id,
        name: name.trim(),
        currency: currency,
        hourlyRate: hourlyRate,
        createdAt: existing?.createdAt ?? DateTime.now(),
      ),
    );
    await refresh();
    if (id == 0) emit(state.copyWith(selectedProjectId: saved.id));
    final active = state.runningTimer;
    if (id != 0 &&
        active?.projectId == id &&
        active!.projectName != saved.name) {
      final renamedTimer = active.copyWith(projectName: saved.name);
      await _timerService.start(renamedTimer);
      emit(state.copyWith(runningTimer: renamedTimer));
    }
    return saved;
  }

  Future<void> deleteProject(Project project) async {
    if (state.runningTimer?.projectId == project.id) {
      throw const LocalizedException(
        LocaleKeys.errors_activeTimerProjectDelete,
      );
    }
    await _repository.deleteProject(project.id);
    await refresh();
  }

  Future<TimeEntry> saveEntry(TimeEntry entry) async {
    if (entry.end.isBefore(entry.start)) {
      throw const LocalizedException(LocaleKeys.errors_endBeforeStart);
    }
    final validBreaks = entry.breaks.where(
      (item) =>
          !item.end.isBefore(item.start) &&
          !item.start.isBefore(entry.start) &&
          !item.end.isAfter(entry.end),
    );
    if (validBreaks.length != entry.breaks.length) {
      throw const LocalizedException(LocaleKeys.errors_breakOutsideEntry);
    }
    final orderedBreaks = [...entry.breaks]
      ..sort((a, b) => a.start.compareTo(b.start));
    for (var index = 1; index < orderedBreaks.length; index++) {
      if (orderedBreaks[index].start.isBefore(orderedBreaks[index - 1].end)) {
        throw const LocalizedException(LocaleKeys.errors_breakOverlap);
      }
    }
    final saved = await _repository.saveEntry(entry);
    await refresh();
    return saved;
  }

  Future<void> deleteEntry(int id) async {
    await _repository.deleteEntries({id});
    await refresh();
  }

  void toggleEntrySelection(int id) {
    final selected = {...state.selectedEntryIds};
    selected.contains(id) ? selected.remove(id) : selected.add(id);
    emit(state.copyWith(selectedEntryIds: selected));
  }

  void clearSelection() => emit(state.copyWith(selectedEntryIds: const {}));

  Future<void> markSelectedPaid() async {
    await _repository.markEntriesPaid(state.selectedEntryIds);
    emit(state.copyWith(selectedEntryIds: const {}));
    await refresh();
  }

  Future<void> deleteSelected() async {
    await _repository.deleteEntries(state.selectedEntryIds);
    emit(state.copyWith(selectedEntryIds: const {}));
    await refresh();
  }

  Future<bool> punchIn(Project project) async {
    if (state.runningTimer != null) return true;
    final permission = await _timerService.ensureNotificationPermission();
    final timer = RunningTimer(
      projectId: project.id,
      projectName: project.name,
      currency: project.currency,
      hourlyRate: project.hourlyRate,
      startedAt: DateTime.now(),
    );
    await _timerService.start(timer);
    emit(state.copyWith(runningTimer: timer, now: DateTime.now()));
    _startTicker();
    return permission;
  }

  Future<void> toggleBreak() async {
    final timer = state.runningTimer;
    if (timer == null) return;
    final now = DateTime.now();
    late RunningTimer changed;
    if (timer.breakStartedAt == null) {
      changed = timer.copyWith(breakStartedAt: now);
    } else {
      changed = timer.copyWith(
        completedBreaks: [
          ...timer.completedBreaks,
          BreakPeriod(start: timer.breakStartedAt!, end: now),
        ],
        clearBreak: true,
      );
    }
    await _timerService.toggleBreak();
    emit(state.copyWith(runningTimer: changed, now: now));
  }

  Future<TimeEntry?> punchOut({bool requestEditor = true}) async {
    final timer = state.runningTimer;
    if (timer == null) return null;
    final now = DateTime.now();
    final breaks = [...timer.completedBreaks];
    if (timer.breakStartedAt != null) {
      breaks.add(BreakPeriod(start: timer.breakStartedAt!, end: now));
    }
    final entry = await _repository.saveEntry(
      TimeEntry(
        id: 0,
        projectId: timer.projectId,
        hourlyRateSnapshot: timer.hourlyRate,
        currencySnapshot: timer.currency,
        start: timer.startedAt,
        end: now,
        breaks: breaks,
        createdAt: now,
      ),
    );
    await _timerService.stop();
    _ticker?.cancel();
    final entries = await _repository.getEntries();
    emit(
      state.copyWith(
        entries: entries,
        clearRunningTimer: true,
        now: now,
        editorEntryId: requestEditor ? entry.id : null,
        clearEditorEntry: !requestEditor,
        editorRequestSerial: requestEditor
            ? state.editorRequestSerial + 1
            : state.editorRequestSerial,
      ),
    );
    return entry;
  }

  Future<bool> checkNativeActions() async {
    final shouldOpenTimer = await _timerService.consumeOpenTimerRequest();
    final pending = await _timerService.consumePendingPunchOut();
    if (pending != null) {
      await _storePendingPunchOut(pending);
      return false;
    }
    final restored = await _timerService.restore();
    if (restored != null) {
      emit(state.copyWith(runningTimer: restored, now: DateTime.now()));
      _startTicker();
    }
    return shouldOpenTimer && restored != null;
  }

  void clearEditorRequest() => emit(state.copyWith(clearEditorEntry: true));

  Future<void> _storePendingPunchOut(RunningTimer pending) async {
    final end = pending.stoppedAt ?? DateTime.now();
    final breaks = [...pending.completedBreaks];
    if (pending.breakStartedAt != null) {
      breaks.add(BreakPeriod(start: pending.breakStartedAt!, end: end));
    }
    final entry = await _repository.saveEntry(
      TimeEntry(
        id: 0,
        projectId: pending.projectId,
        hourlyRateSnapshot: pending.hourlyRate,
        currencySnapshot: pending.currency,
        start: pending.startedAt,
        end: end,
        breaks: breaks,
        createdAt: end,
      ),
    );
    _ticker?.cancel();
    final entries = await _repository.getEntries();
    emit(
      state.copyWith(
        entries: entries,
        clearRunningTimer: true,
        now: end,
        editorEntryId: entry.id,
        editorRequestSerial: state.editorRequestSerial + 1,
      ),
    );
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isClosed && state.runningTimer != null) {
        emit(state.copyWith(now: DateTime.now()));
      }
    });
  }

  @override
  Future<void> close() async {
    _ticker?.cancel();
    await _repository.close();
    return super.close();
  }
}
