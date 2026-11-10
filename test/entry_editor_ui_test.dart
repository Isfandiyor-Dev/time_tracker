import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracker/core/theme/app_theme.dart';
import 'package:time_tracker/domain/entities/project.dart';
import 'package:time_tracker/domain/entities/running_timer.dart';
import 'package:time_tracker/domain/entities/time_entry.dart';
import 'package:time_tracker/domain/repositories/tracker_repository.dart';
import 'package:time_tracker/domain/services/timer_service.dart';
import 'package:time_tracker/presentation/cubit/tracker_cubit.dart';
import 'package:time_tracker/presentation/pages/entry_editor_page.dart';
import 'package:time_tracker/presentation/pages/notes_page.dart';

void main() {
  testWidgets('entry editor uses separate date/time controls and break total', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final cubit = TrackerCubit(_MemoryRepository(), _NoopTimerService());
    await cubit.initialize();
    addTearDown(cubit.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const EntryEditorPage(initialProjectId: 1),
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (final key in const [
      'start-date-button',
      'start-time-button',
      'end-date-button',
      'end-time-button',
    ]) {
      expect(find.byKey(ValueKey(key)), findsOneWidget);
    }
    final startDateRect = tester.getRect(
      find.byKey(const ValueKey('start-date-button')),
    );
    final startTimeRect = tester.getRect(
      find.byKey(const ValueKey('start-time-button')),
    );
    expect(startDateRect.right, lessThan(startTimeRect.left));
    expect(find.text('Total:'), findsOneWidget);
    expect(find.text('0h 00m'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final addBreak = find.byKey(const ValueKey('add-break-button'));
    await tester.ensureVisible(addBreak);
    await tester.tap(addBreak);
    await tester.pumpAndSettle();

    expect(find.text('Break start'), findsOneWidget);
    expect(find.text('Break end'), findsOneWidget);
    expect(find.textContaining('Length'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('notes actions match outlined and filled reference styles', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const NotesPage(initialValue: ''),
      ),
    );
    await tester.pumpAndSettle();

    final cancel = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Cancel'),
    );
    final done = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Done'),
    );
    expect(cancel.style?.side?.resolve({})?.color, AppColors.text);
    expect(done.style?.backgroundColor?.resolve({}), AppColors.lime);
    expect(tester.getSize(find.text('Cancel')).height, greaterThan(15));
    expect(tester.takeException(), isNull);
  });
}

class _MemoryRepository implements TrackerRepository {
  final projects = [
    Project(
      id: 1,
      name: 'Volt Auto',
      currency: 'USD',
      hourlyRate: 5,
      createdAt: DateTime(2026, 8, 21),
    ),
  ];

  @override
  Future<void> close() async {}

  @override
  Future<void> deleteEntries(Set<int> ids) async {}

  @override
  Future<void> deleteProject(int id) async {}

  @override
  Future<List<TimeEntry>> getEntries() async => [];

  @override
  Future<List<Project>> getProjects() async => projects;

  @override
  Future<void> markEntriesPaid(Set<int> ids) async {}

  @override
  Future<TimeEntry> saveEntry(TimeEntry entry) async => entry;

  @override
  Future<Project> saveProject(Project project) async => project;
}

class _NoopTimerService implements TimerService {
  @override
  Future<void> setLocale(String languageCode) async {}

  @override
  Future<bool> consumeOpenTimerRequest() async => false;

  @override
  Future<RunningTimer?> consumePendingPunchOut() async => null;

  @override
  Future<bool> ensureNotificationPermission() async => false;

  @override
  Future<RunningTimer?> restore() async => null;

  @override
  Future<void> start(RunningTimer timer) async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> toggleBreak() async {}
}
