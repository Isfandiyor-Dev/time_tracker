part of 'tracker_cubit.dart';

enum TrackerStatus { loading, ready, failure }

class TrackerState extends Equatable {
  const TrackerState({
    this.status = TrackerStatus.loading,
    this.projects = const [],
    this.entries = const [],
    this.selectedProjectId,
    this.selectedEntryIds = const {},
    this.runningTimer,
    this.now,
    this.editorEntryId,
    this.editorRequestSerial = 0,
    this.errorMessage,
  });

  final TrackerStatus status;
  final List<Project> projects;
  final List<TimeEntry> entries;
  final int? selectedProjectId;
  final Set<int> selectedEntryIds;
  final RunningTimer? runningTimer;
  final DateTime? now;
  final int? editorEntryId;
  final int editorRequestSerial;
  final String? errorMessage;

  Project? get selectedProject {
    for (final project in projects) {
      if (project.id == selectedProjectId) return project;
    }
    return projects.isEmpty ? null : projects.first;
  }

  List<TimeEntry> get visibleEntries => entries
      .where((entry) => entry.projectId == selectedProjectId)
      .toList(growable: false);

  List<TimeEntry> get selectedEntries => entries
      .where((entry) => selectedEntryIds.contains(entry.id))
      .toList(growable: false);

  bool get isSelecting => selectedEntryIds.isNotEmpty;

  TrackerState copyWith({
    TrackerStatus? status,
    List<Project>? projects,
    List<TimeEntry>? entries,
    int? selectedProjectId,
    bool clearSelectedProject = false,
    Set<int>? selectedEntryIds,
    RunningTimer? runningTimer,
    bool clearRunningTimer = false,
    DateTime? now,
    int? editorEntryId,
    bool clearEditorEntry = false,
    int? editorRequestSerial,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TrackerState(
      status: status ?? this.status,
      projects: projects ?? this.projects,
      entries: entries ?? this.entries,
      selectedProjectId: clearSelectedProject
          ? null
          : selectedProjectId ?? this.selectedProjectId,
      selectedEntryIds: selectedEntryIds ?? this.selectedEntryIds,
      runningTimer: clearRunningTimer
          ? null
          : runningTimer ?? this.runningTimer,
      now: now ?? this.now,
      editorEntryId: clearEditorEntry
          ? null
          : editorEntryId ?? this.editorEntryId,
      editorRequestSerial: editorRequestSerial ?? this.editorRequestSerial,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    projects,
    entries,
    selectedProjectId,
    selectedEntryIds,
    runningTimer,
    now,
    editorEntryId,
    editorRequestSerial,
    errorMessage,
  ];
}
