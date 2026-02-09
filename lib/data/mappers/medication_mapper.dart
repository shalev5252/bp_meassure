import 'package:bp_monitor/data/database.dart';
import 'package:bp_monitor/domain/entities/medication_entity.dart';
import 'package:drift/drift.dart';

/// Maps between [PatientMedication] (Drift row) and [MedicationEntity] (domain).
class MedicationMapper {
  const MedicationMapper();

  MedicationEntity fromRow(PatientMedication row) => MedicationEntity(
        medicationId: row.medicationId,
        patientId: row.patientId,
        name: row.name,
        doseText: row.doseText,
        frequencyText: row.frequencyText,
        isActive: row.isActive,
        startedOn: row.startedOn,
        updatedAt: row.updatedAt,
      );

  PatientMedicationsCompanion toCompanion(MedicationEntity entity) =>
      PatientMedicationsCompanion(
        medicationId: Value(entity.medicationId),
        patientId: Value(entity.patientId),
        name: Value(entity.name),
        doseText: Value(entity.doseText),
        frequencyText: Value(entity.frequencyText),
        isActive: Value(entity.isActive),
        startedOn: Value(entity.startedOn),
        updatedAt: Value(entity.updatedAt),
      );
}
