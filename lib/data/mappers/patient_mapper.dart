import 'package:bp_monitor/data/database.dart';
import 'package:bp_monitor/domain/entities/patient_entity.dart';
import 'package:drift/drift.dart';

/// Maps between [Patient] (Drift row) and [PatientEntity] (domain).
class PatientMapper {
  const PatientMapper();

  PatientEntity fromRow(Patient row) => PatientEntity(
        patientId: row.patientId,
        userId: row.userId,
        displayName: row.displayName,
        dateOfBirth: row.dateOfBirth,
        sex: row.sex,
        heightCm: row.heightCm,
        weightKg: row.weightKg,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  PatientsCompanion toCompanion(PatientEntity entity) => PatientsCompanion(
        patientId: Value(entity.patientId),
        userId: Value(entity.userId),
        displayName: Value(entity.displayName),
        dateOfBirth: Value(entity.dateOfBirth),
        sex: Value(entity.sex),
        heightCm: Value(entity.heightCm),
        weightKg: Value(entity.weightKg),
        createdAt: Value(entity.createdAt),
        updatedAt: Value(entity.updatedAt),
      );
}
