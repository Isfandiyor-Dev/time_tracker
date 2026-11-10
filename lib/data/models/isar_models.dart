import 'package:isar_community/isar.dart';

import '../../domain/entities/project.dart';
import '../../domain/entities/time_entry.dart';

part 'isar_models.g.dart';

@collection
class ProjectRecord {
  Id id = Isar.autoIncrement;
  late String name;
  late String currency;
  late double hourlyRate;
  late DateTime createdAt;

  Project toEntity() => Project(
    id: id,
    name: name,
    currency: currency,
    hourlyRate: hourlyRate,
    createdAt: createdAt,
  );

  static ProjectRecord fromEntity(Project value) {
    return ProjectRecord()
      ..id = value.id == 0 ? Isar.autoIncrement : value.id
      ..name = value.name
      ..currency = value.currency
      ..hourlyRate = value.hourlyRate
      ..createdAt = value.createdAt;
  }
}

@embedded
class BreakRecord {
  DateTime? start;
  DateTime? end;

  BreakPeriod? toEntity() {
    if (start == null || end == null) return null;
    return BreakPeriod(start: start!, end: end!);
  }

  static BreakRecord fromEntity(BreakPeriod value) {
    return BreakRecord()
      ..start = value.start
      ..end = value.end;
  }
}

@collection
class TimeEntryRecord {
  Id id = Isar.autoIncrement;

  @Index()
  late int projectId;
  late double hourlyRateSnapshot;
  late String currencySnapshot;

  @Index()
  late DateTime start;
  late DateTime end;
  List<BreakRecord> breaks = [];
  String notes = '';

  @Index()
  bool isPaid = false;
  late DateTime createdAt;

  TimeEntry toEntity() => TimeEntry(
    id: id,
    projectId: projectId,
    hourlyRateSnapshot: hourlyRateSnapshot,
    currencySnapshot: currencySnapshot,
    start: start,
    end: end,
    breaks: breaks.map((b) => b.toEntity()).whereType<BreakPeriod>().toList(),
    notes: notes,
    isPaid: isPaid,
    createdAt: createdAt,
  );

  static TimeEntryRecord fromEntity(TimeEntry value) {
    return TimeEntryRecord()
      ..id = value.id == 0 ? Isar.autoIncrement : value.id
      ..projectId = value.projectId
      ..hourlyRateSnapshot = value.hourlyRateSnapshot
      ..currencySnapshot = value.currencySnapshot
      ..start = value.start
      ..end = value.end
      ..breaks = value.breaks.map(BreakRecord.fromEntity).toList()
      ..notes = value.notes
      ..isPaid = value.isPaid
      ..createdAt = value.createdAt;
  }
}
