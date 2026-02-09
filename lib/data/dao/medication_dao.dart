import 'package:bp_monitor/data/dao/tables.dart';
import 'package:bp_monitor/data/database.dart';
import 'package:drift/drift.dart';

part 'medication_dao.g.dart';

@DriftAccessor(tables: [PatientMedications])
class MedicationDao extends DatabaseAccessor<AppDatabase>
    with _$MedicationDaoMixin {
  MedicationDao(super.db);

  Future<List<PatientMedication>> getByPatientId(
    String patientId, {
    bool? activeOnly,
  }) {
    final query = select(patientMedications)
      ..where((t) => t.patientId.equals(patientId));
    if (activeOnly == true) {
      query.where((t) => t.isActive.equals(true));
    }
    return query.get();
  }

  Future<void> upsertMedication(PatientMedicationsCompanion entry) =>
      into(patientMedications).insertOnConflictUpdate(entry);

  Future<void> deleteMedication(String medicationId) =>
      (delete(patientMedications)
            ..where((t) => t.medicationId.equals(medicationId)))
          .go();
}
