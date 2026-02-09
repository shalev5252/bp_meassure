import 'package:bp_monitor/data/dao/tables.dart';
import 'package:bp_monitor/data/database.dart';
import 'package:drift/drift.dart';

part 'patient_dao.g.dart';

@DriftAccessor(tables: [Patients])
class PatientDao extends DatabaseAccessor<AppDatabase> with _$PatientDaoMixin {
  PatientDao(super.db);

  Future<void> upsertPatient(PatientsCompanion patient) =>
      into(patients).insertOnConflictUpdate(patient);

  Future<Patient?> getPatientByUserId(String userId) =>
      (select(patients)..where((t) => t.userId.equals(userId)))
          .getSingleOrNull();

  Future<Patient?> getPatientById(String patientId) =>
      (select(patients)..where((t) => t.patientId.equals(patientId)))
          .getSingleOrNull();

  Future<void> deletePatient(String patientId) =>
      (delete(patients)..where((t) => t.patientId.equals(patientId))).go();
}
