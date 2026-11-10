import '../entities/project.dart';
import '../entities/time_entry.dart';

abstract interface class TrackerRepository {
  Future<List<Project>> getProjects();
  Future<List<TimeEntry>> getEntries();
  Future<Project> saveProject(Project project);
  Future<void> deleteProject(int id);
  Future<TimeEntry> saveEntry(TimeEntry entry);
  Future<void> deleteEntries(Set<int> ids);
  Future<void> markEntriesPaid(Set<int> ids);
  Future<void> close();
}
