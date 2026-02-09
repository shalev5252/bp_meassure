import 'package:bp_monitor/core/errors.dart';
import 'package:bp_monitor/domain/entities/patient_entity.dart';

/// Contract for patient profile data access (single patient per user).
abstract class PatientRepository {
  Future<Result<void>> upsert(PatientEntity patient);
  Future<Result<PatientEntity?>> getByUserId(String userId);
  Future<Result<PatientEntity?>> getById(String patientId);
  Future<Result<void>> delete(String patientId);
}
