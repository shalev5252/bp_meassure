import 'package:bp_monitor/data/dao/tables.dart';
import 'package:bp_monitor/data/database.dart';
import 'package:drift/drift.dart';

part 'reading_dao.g.dart';

@DriftAccessor(tables: [Readings])
class ReadingDao extends DatabaseAccessor<AppDatabase> with _$ReadingDaoMixin {
  ReadingDao(super.db);

  Future<List<Reading>> getByPatientId(
    String patientId, {
    DateTime? from,
    DateTime? to,
    String? qualityFilter,
  }) {
    final query = select(readings)
      ..where((t) => t.patientId.equals(patientId))
      ..orderBy([(t) => OrderingTerm.desc(t.takenAt)]);
    if (from != null) {
      query.where((t) => t.takenAt.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where((t) => t.takenAt.isSmallerOrEqualValue(to));
    }
    if (qualityFilter != null) {
      query.where((t) => t.measurementQuality.equals(qualityFilter));
    }
    return query.get();
  }

  Future<Reading?> getById(String readingId) =>
      (select(readings)..where((t) => t.readingId.equals(readingId)))
          .getSingleOrNull();

  Future<void> upsertReading(ReadingsCompanion entry) =>
      into(readings).insertOnConflictUpdate(entry);

  Future<void> deleteReading(String readingId) =>
      (delete(readings)..where((t) => t.readingId.equals(readingId))).go();

  Future<int> countByPatientId(String patientId) async {
    final count = countAll();
    final query = selectOnly(readings)
      ..addColumns([count])
      ..where(readings.patientId.equals(patientId));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }
}
