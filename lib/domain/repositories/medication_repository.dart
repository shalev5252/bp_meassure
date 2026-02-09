import 'package:bp_monitor/core/errors.dart';
import 'package:bp_monitor/domain/entities/medication_entity.dart';

/// Contract for patient medication data access.
abstract class MedicationRepository {
  Future<Result<List<MedicationEntity>>> getByPatientId(
    String patientId, {
    bool? activeOnly,
  });
  Future<Result<void>> upsert(MedicationEntity medication);
  Future<Result<void>> delete(String medicationId);
}
