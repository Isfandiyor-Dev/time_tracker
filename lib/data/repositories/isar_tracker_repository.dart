import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/project.dart';
import '../../domain/entities/time_entry.dart';
import '../../domain/repositories/tracker_repository.dart';
import '../models/isar_models.dart';

class IsarTrackerRepository implements TrackerRepository {
  IsarTrackerRepository._(this._isar);

  final Isar _isar;

  static Future<IsarTrackerRepository> open() async {
    final directory = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [ProjectRecordSchema, TimeEntryRecordSchema],
      directory: directory.path,
      name: 'time_tracker',
    );
    return IsarTrackerRepository._(isar);
  }

  @override
  Future<List<Project>> getProjects() async {
    final records = await _isar.projectRecords
        .where()
        .sortByCreatedAt()
        .findAll();
    return records.map((item) => item.toEntity()).toList(growable: false);
  }

  @override
  Future<List<TimeEntry>> getEntries() async {
    final records = await _isar.timeEntryRecords
        .where()
        .sortByStartDesc()
        .findAll();
    return records.map((item) => item.toEntity()).toList(growable: false);
  }

  @override
  Future<Project> saveProject(Project project) async {
    final record = ProjectRecord.fromEntity(project);
    await _isar.writeTxn(() async => _isar.projectRecords.put(record));
    return record.toEntity();
  }

  @override
  Future<void> deleteProject(int id) async {
    await _isar.writeTxn(() async {
      await _isar.timeEntryRecords.filter().projectIdEqualTo(id).deleteAll();
      await _isar.projectRecords.delete(id);
    });
  }

  @override
  Future<TimeEntry> saveEntry(TimeEntry entry) async {
    final record = TimeEntryRecord.fromEntity(entry);
    await _isar.writeTxn(() async => _isar.timeEntryRecords.put(record));
    return record.toEntity();
  }

  @override
  Future<void> deleteEntries(Set<int> ids) async {
    await _isar.writeTxn(
      () async => _isar.timeEntryRecords.deleteAll(ids.toList()),
    );
  }

  @override
  Future<void> markEntriesPaid(Set<int> ids) async {
    await _isar.writeTxn(() async {
      final records = await _isar.timeEntryRecords.getAll(ids.toList());
      final changed = records
          .whereType<TimeEntryRecord>()
          .map((item) => item..isPaid = true)
          .toList();
      await _isar.timeEntryRecords.putAll(changed);
    });
  }

  @override
  Future<void> close() => _isar.close();
}
